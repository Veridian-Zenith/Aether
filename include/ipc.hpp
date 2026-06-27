#pragma once

#include "kernel.hpp"
#include <atomic>
#include <array>
#include <optional>
#include <unordered_map>
#include <memory>
#include <mutex>

namespace Aether {

    enum class MessageType : uint32_t { Request, Response, Signal };

    struct IPCMessage {
        ProcessId sender;
        ProcessId target;
        MessageType type;
        uint64_t payload;
    };

    template<size_t Capacity>
    class LockFreeRingBuffer {
    public:
        bool push(const IPCMessage& msg) noexcept {
            size_t head = m_head.load(std::memory_order_relaxed);
            size_t next_head = (head + 1) % (Capacity + 1);
            if (next_head == m_tail.load(std::memory_order_acquire)) return false;

            m_buffer[head] = msg;
            m_head.store(next_head, std::memory_order_release);
            return true;
        }

        std::optional<IPCMessage> pop() noexcept {
            size_t tail = m_tail.load(std::memory_order_relaxed);
            if (tail == m_head.load(std::memory_order_acquire)) return std::nullopt;

            IPCMessage msg = m_buffer[tail];
            m_tail.store((tail + 1) % (Capacity + 1), std::memory_order_release);
            return msg;
        }

        [[nodiscard]] bool empty() const noexcept {
            return m_head.load(std::memory_order_acquire) == m_tail.load(std::memory_order_acquire);
        }

        [[nodiscard]] bool full() const noexcept {
            size_t next_head = (m_head.load(std::memory_order_relaxed) + 1) % (Capacity + 1);
            return next_head == m_tail.load(std::memory_order_acquire);
        }

    private:
        std::array<IPCMessage, Capacity + 1> m_buffer{};
        std::atomic<size_t> m_head{0};
        std::atomic<size_t> m_tail{0};
    };

    class IpcBroker {
    public:
        IpcBroker();

        bool createChannel(ProcessId pid) noexcept;
        void removeChannel(ProcessId pid) noexcept;
        bool hasChannel(ProcessId pid) const noexcept;

        bool sendMessage(ProcessId target, const IPCMessage& msg) noexcept;
        std::optional<IPCMessage> receiveMessage(ProcessId listener) noexcept;

        bool sendRequest(ProcessId target, ProcessId sender, uint64_t payload) noexcept;
        bool sendResponse(ProcessId target, ProcessId sender, uint64_t payload) noexcept;
        bool sendSignal(ProcessId target, ProcessId sender, uint64_t payload) noexcept;

        [[nodiscard]] size_t channelCount() const noexcept;

    private:
        struct alignas(64) Channel {
            LockFreeRingBuffer<256> buffer;
            std::atomic<bool> active{false};
        };

        std::unordered_map<ProcessId, std::unique_ptr<Channel>> m_channels;
        mutable std::mutex m_mutex;
    };

} // namespace Aether
