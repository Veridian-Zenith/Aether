/**
 * @file echo.cpp
 * @brief Implementation of the Echo Service
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "../../include/services/echo.hpp"

namespace Aether {

    void EchoService::run() noexcept {
        // Prototype: Receive one message and echo back
        auto msg_opt = m_ipc.receiveMessage(m_pid);
        if(!msg_opt) return;
        IPCMessage msg = *msg_opt;
        
        IPCMessage reply = { m_pid, msg.sender, MessageType::Response, msg.payload };
        m_ipc.sendMessage(msg.sender, reply);
    }

} // namespace Aether
