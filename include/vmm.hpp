/**
 * @file vmm.hpp
 * @brief The Arcane Memory Pool (Virtual Memory Manager)
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "kernel.hpp"
#include <unordered_map>
#include <vector>

namespace Aether {

    /**
     * @brief Manages virtual memory allocations for processes within the realm.
     */
    class ArcaneMemoryPool {
    public:
        /**
         * @brief Allocates a page of memory for a process.
         */
        [[nodiscard]] std::expected<Address, ErrorCode> allocatePage(ProcessId pid) noexcept;

        /**
         * @brief Frees a page of memory from a process.
         */
        void freePage(ProcessId pid, Address addr) noexcept;

    private:
        // pid -> vector of addresses
        std::unordered_map<ProcessId, std::vector<Address>> m_allocations;
        Address m_next_free_addr = 0x10000000; // Base address
    };

} // namespace Aether
