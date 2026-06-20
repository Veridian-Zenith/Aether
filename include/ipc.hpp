/**
 * @file ipc.hpp
 * @brief The Runic Nexus (Lock-Free IPC Broker)
 * @copyright Copyright (C) 2026 Veridian Zenith
 */

#pragma once

#include "kernel.hpp"
#include <atomic>
#include <array>
#include <optional>

namespace Aether {

    enum class MessageType : uint32_t { Request, Response, Signal };

    struct IPCMessage {
        ProcessId sender;
        MessageType type;
        uint64_t payload;
    };

    /**
     * @brief Lock-free ring buffer for IPC.
     */
    template<size_t Capacity>
    class LockFreeRingBuffer {
    public:
        bool push(const IPCMessage& msg) noexcept {
            size_t head = m_head.load(std::memory_order_relaxed);
            size_t next_head = (head + 1) % Capacity;
            if (next_head == m_tail.load(std::memory_order_acquire)) return false; // Buffer full
            
            m_buffer[head] = msg;
            m_head.store(next_head, std::memory_order_release);
            return true;
        }

        std::optional<IPCMessage> pop() noexcept {
            size_t tail = m_tail.load(std::memory_order_relaxed);
            if (tail == m_head.load(std::memory_order_acquire)) return std::nullopt; // Buffer empty
            
            IPCMessage msg = m_buffer[tail];
            m_tail.store((tail + 1) % Capacity, std::memory_order_release);
            return msg;
        }

    private:
        std::array<IPCMessage, Capacity> m_buffer;
        std::atomic<size_t> m_head{0};
        std::atomic<size_t> m_tail{0};
    };

    class IpcBroker {
    public:
        void sendMessage(ProcessId target, const IPCMessage& msg) noexcept;
        std::optional<IPCMessage> receiveMessage(ProcessId listener) noexcept;

    private:
        // Simplification: Shared buffer for prototype; production would map per-process channels
        LockFreeRingBuffer<1024> m_global_nexus;
    };

} // namespace Aether
