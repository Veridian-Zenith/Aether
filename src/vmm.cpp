/**
 * @file vmm.cpp
 * @brief Implementation of the Arcane Memory Pool
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "vmm.hpp"

namespace Aether {

    std::expected<Address, ErrorCode> ArcaneMemoryPool::allocatePage(ProcessId pid) noexcept {
        // Prototype: simple bump allocator
        if (m_next_free_addr > 0xFFFFFFFF) {
            return std::unexpected(ErrorCode::PoolExhausted);
        }

        Address addr = m_next_free_addr;
        m_allocations[pid].push_back(addr);
        m_next_free_addr += k_page_size;

        return addr;
    }

    void ArcaneMemoryPool::freePage(ProcessId pid, Address addr) noexcept {
        auto it = m_allocations.find(pid);
        if (it != m_allocations.end()) {
            auto& pages = it->second;
            std::erase(pages, addr);
        }
    }

} // namespace Aether
