/**
 * @file capability.cpp
 * @brief Implementation of the Sigil Registry
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "capability.hpp"

namespace Aether {

    void SigilRegistry::ordain(ProcessId pid, Sigil power) noexcept {
        m_table[pid].insert(power);
    }

    bool SigilRegistry::isWorthy(ProcessId pid, Sigil power) const noexcept {
        // Kernel is eternally worthy
        if (pid == k_kernel_pid) return true;

        auto it = m_table.find(pid);
        if (it == m_table.end()) {
            return false;
        }
        return it->second.contains(power);
    }

    void SigilRegistry::revoke(ProcessId pid, Sigil power) noexcept {
        auto it = m_table.find(pid);
        if (it != m_table.end()) {
            it->second.erase(power);
        }
    }

    void SigilRegistry::banish(ProcessId pid) noexcept {
        m_table.erase(pid);
    }

} // namespace Aether
