/**
 * @file hal.cpp
 * @brief Implementation of the Primal Forces (HAL)
 */

#include "hal.hpp"
#include <iostream>

namespace Aether::HAL {

    void outb(uint16_t port, uint8_t val) noexcept {
        // Prototype: In production, this maps to privileged x86 instructions or I/O space
        std::println("HAL: Writing {:#x} to port {:#x}", val, port);
    }

    uint8_t inb(uint16_t port) noexcept {
        std::println("HAL: Reading from port {:#x}", port);
        return 0;
    }

    void write32(Address addr, uint32_t val) noexcept {
        *reinterpret_cast<volatile uint32_t*>(addr) = val;
    }

    uint32_t read32(Address addr) noexcept {
        return *reinterpret_cast<volatile uint32_t*>(addr);
    }

    void registerIrq(uint32_t irq, IrqHandler handler) noexcept {
        std::println("HAL: Registering handler for IRQ {}", irq);
        // Store in a global interrupt table
    }

    std::expected<DmaMapping, ErrorCode> mapDma(Address virtual_addr, size_t size) noexcept {
        // Production: Needs IOMMU protection validation
        return DmaMapping{virtual_addr, size};
    }

} // namespace Aether::HAL
