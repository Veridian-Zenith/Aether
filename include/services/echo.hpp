/**
 * @file echo.hpp
 * @brief The Echo Service (Runic Echo)
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "../kernel.hpp"
#include "../ipc.hpp"

namespace Aether {

    /**
     * @brief A simple service that echoes IPC messages back to the sender.
     */
    class EchoService {
    public:
        EchoService(ProcessId pid, IpcBroker& ipc) : m_pid(pid), m_ipc(ipc) {}

        /**
         * @brief Runs the service loop.
         */
        void run() noexcept;

    private:
        ProcessId m_pid;
        IpcBroker& m_ipc;
    };

} // namespace Aether
