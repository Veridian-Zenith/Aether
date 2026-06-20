/**
 * @file gateway.cpp
 * @brief Implementation of the Aether Gateway
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "gateway.hpp"

namespace Aether {

    std::expected<uint64_t, ErrorCode> AetherGateway::handleSyscall(ProcessId pid, uint64_t syscall_nr, uint64_t arg1) noexcept {
        // Simple mapping for prototype
        switch (syscall_nr) {
            case 1: // sys_write (simulation)
                if (!m_sigils.isWorthy(pid, Sigil::Write)) return std::unexpected(ErrorCode::SigilDenied);
                // In a real system, this would translate to a message to a VFS service
                return 0; 
                
            case 9: { // sys_mmap (simulation)
                if (!m_sigils.isWorthy(pid, Sigil::Read)) return std::unexpected(ErrorCode::SigilDenied);
                auto res = m_vmm.allocatePage(pid);
                if (!res) return std::unexpected(res.error());
                return *res;
            }

            default:
                return std::unexpected(ErrorCode::GatewayMalformed);
        }
    }

} // namespace Aether
