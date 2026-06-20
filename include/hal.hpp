/**
 * @file hal.hpp
 * @brief The Primal Forces (Hardware Abstraction Layer)
 * @copyright Copyright (C) 2026 Veridian Zenith
 */

#pragma once

#include "kernel.hpp"
#include <functional>

namespace Aether::HAL {

    /**
     * @brief I/O primitives for raw hardware manipulation.
     */
    void outb(uint16_t port, uint8_t val) noexcept;
    uint8_t inb(uint16_t port) noexcept;

    /**
     * @brief Memory-Mapped I/O operations.
     */
    void write32(Address addr, uint32_t val) noexcept;
    uint32_t read32(Address addr) noexcept;

    /**
     * @brief Interrupt management (hooking the hardware).
     */
    using IrqHandler = std::function<void()>;
    void registerIrq(uint32_t irq, IrqHandler handler) noexcept;

    /**
     * @brief DMA (Direct Memory Access) management.
     */
    struct DmaMapping {
        Address physical;
        size_t size;
    };
    std::expected<DmaMapping, ErrorCode> mapDma(Address virtual_addr, size_t size) noexcept;

} // namespace Aether::HAL
