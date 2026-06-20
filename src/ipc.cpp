/**
 * @file ipc.cpp
 * @brief Implementation of the Lock-Free Runic Nexus
 */

#include "ipc.hpp"

namespace Aether {

    void IpcBroker::sendMessage(ProcessId target, const IPCMessage& msg) noexcept {
        // In production, this would route to target's specific LockFreeRingBuffer
        while(!m_global_nexus.push(msg)) {
            // Spin or yield
        }
    }

    std::optional<IPCMessage> IpcBroker::receiveMessage(ProcessId listener) noexcept {
        return m_global_nexus.pop();
    }

} // namespace Aether
