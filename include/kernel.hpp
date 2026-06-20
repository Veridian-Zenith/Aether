/**
 * @file kernel.hpp
 * @brief Global types, errors, and concepts of the Aether Microkernel
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include <string>
#include <string_view>
#include <vector>
#include <cstdint>
#include <expected>
#include <concepts>

namespace Aether {

    /**
     * @brief Arcane Error Codes representing failures within the Digital Realms.
     */
    enum class ErrorCode : uint32_t {
        Success = 0,
        SigilDenied = 1,        // Permission denied (no required sigil)
        RealmNotFound = 2,      // Process/Thread or target not found
        NexusBlocked = 3,       // IPC blocked or target not receptive
        PoolExhausted = 4,      // Out of memory / paging failure
        LoomOverflow = 5,       // Scheduler capacity exceeded
        GatewayMalformed = 6,   // Invalid Linux system call translation
        InvalidSpell = 7        // General invalid argument or operation
    };

    /**
     * @brief Translates an ErrorCode to its mortal string representation.
     */
    constexpr std::string_view strerror(ErrorCode code) noexcept {
        switch (code) {
            case ErrorCode::Success:          return "Success";
            case ErrorCode::SigilDenied:      return "SigilDenied: Required power is not ordained";
            case ErrorCode::RealmNotFound:    return "RealmNotFound: The target sphere does not exist";
            case ErrorCode::NexusBlocked:     return "NexusBlocked: Runic communication channel is blocked";
            case ErrorCode::PoolExhausted:    return "PoolExhausted: The virtual memory pages have collapsed";
            case ErrorCode::LoomOverflow:     return "LoomOverflow: The loom of time cannot handle more threads";
            case ErrorCode::GatewayMalformed: return "GatewayMalformed: The Linux gateway rejected this translation";
            case ErrorCode::InvalidSpell:     return "InvalidSpell: Malformed incantation invoked";
        }
        return "Unknown Chaos";
    }

    using ProcessId = uint32_t;
    using ThreadId = uint32_t;
    using Address = uint64_t;

    constexpr ProcessId k_kernel_pid = 0;
    constexpr size_t k_page_size = 4096;

    /**
     * @brief Concept to ensure types sent through IPC are trivially copyable (Runic Safety).
     */
    template<typename T>
    concept RunicType = std::copyable<T> && std::is_trivially_copyable_v<T>;

} // namespace Aether
