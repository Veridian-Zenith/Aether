/**
 * @file gateway.hpp
 * @brief The Aether Gateway (Linux Syscall Translator)
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "kernel.hpp"
#include "capability.hpp"
#include "ipc.hpp"
#include "vmm.hpp"
#include "scheduler.hpp"

namespace Aether {

    /**
     * @brief Translates host Linux system calls into internal Aether IPC messages.
     */
    class AetherGateway {
    public:
        AetherGateway(SigilRegistry& sigils, IpcBroker& ipc, ArcaneMemoryPool& vmm, WeaverOfTime& scheduler)
            : m_sigils(sigils), m_ipc(ipc), m_vmm(vmm), m_scheduler(scheduler) {}

        /**
         * @brief Intercepts a Linux syscall and translates/routes it.
         */
        std::expected<uint64_t, ErrorCode> handleSyscall(ProcessId pid, uint64_t syscall_nr, uint64_t arg1) noexcept;

    private:
        SigilRegistry& m_sigils;
        IpcBroker& m_ipc;
        ArcaneMemoryPool& m_vmm;
        WeaverOfTime& m_scheduler;
    };

} // namespace Aether
