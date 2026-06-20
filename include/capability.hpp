/**
 * @file capability.hpp
 * @brief The Sigil Registry (Capability Store) safeguarding the realms
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "kernel.hpp"
#include <unordered_map>
#include <unordered_set>

namespace Aether {

    /**
     * @brief Sigils represent fundamental rights granted to spheres of execution (capabilities).
     */
    enum class Sigil : uint32_t {
        Read = 1 << 0,
        Write = 1 << 1,
        Execute = 1 << 2,
        Network = 1 << 3,
        SysAdmin = 1 << 4
    };

    /**
     * @brief High-fantasy representation of the Capability Store.
     */
    class SigilRegistry {
    public:
        /**
         * @brief Grants a specific sigil power to a Process.
         */
        void ordain(ProcessId pid, Sigil power) noexcept;

        /**
         * @brief Checks if a Process is worthy of a specific sigil power.
         */
        [[nodiscard]] bool isWorthy(ProcessId pid, Sigil power) const noexcept;

        /**
         * @brief Revokes a sigil power from a Process.
         */
        void revoke(ProcessId pid, Sigil power) noexcept;

        /**
         * @brief Resets all sigils for a Process (strips it of power).
         */
        void banish(ProcessId pid) noexcept;

    private:
        std::unordered_map<ProcessId, std::unordered_set<Sigil>> m_table;
    };

} // namespace Aether
