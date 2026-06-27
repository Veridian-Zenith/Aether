#include "ipc.hpp"
#include <cassert>

namespace Aether {

    IpcBroker::IpcBroker() {
        m_channels.reserve(64);
        createChannel(k_kernel_pid);
    }

    bool IpcBroker::createChannel(ProcessId pid) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto [it, inserted] = m_channels.try_emplace(pid, std::make_unique<Channel>());
        if (inserted) {
            it->second->active.store(true, std::memory_order_release);
        }
        return inserted;
    }

    void IpcBroker::removeChannel(ProcessId pid) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto it = m_channels.find(pid);
        if (it != m_channels.end()) {
            it->second->active.store(false, std::memory_order_release);
            m_channels.erase(it);
        }
    }

    bool IpcBroker::hasChannel(ProcessId pid) const noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto it = m_channels.find(pid);
        return it != m_channels.end() &&
               it->second->active.load(std::memory_order_acquire);
    }

    bool IpcBroker::sendMessage(ProcessId target, const IPCMessage& msg) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto it = m_channels.find(target);
        if (it == m_channels.end() ||
            !it->second->active.load(std::memory_order_acquire)) {
            return false;
        }
        return it->second->buffer.push(msg);
    }

    std::optional<IPCMessage> IpcBroker::receiveMessage(ProcessId listener) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto it = m_channels.find(listener);
        if (it == m_channels.end()) return std::nullopt;
        return it->second->buffer.pop();
    }

    bool IpcBroker::sendRequest(ProcessId target, ProcessId sender, uint64_t payload) noexcept {
        IPCMessage msg{sender, target, MessageType::Request, payload};
        return sendMessage(target, msg);
    }

    bool IpcBroker::sendResponse(ProcessId target, ProcessId sender, uint64_t payload) noexcept {
        IPCMessage msg{sender, target, MessageType::Response, payload};
        return sendMessage(target, msg);
    }

    bool IpcBroker::sendSignal(ProcessId target, ProcessId sender, uint64_t payload) noexcept {
        IPCMessage msg{sender, target, MessageType::Signal, payload};
        return sendMessage(target, msg);
    }

    size_t IpcBroker::channelCount() const noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_channels.size();
    }

} // namespace Aether
