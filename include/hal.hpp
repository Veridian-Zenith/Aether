#pragma once

#include "kernel.hpp"
#include <functional>
#include <array>
#include <atomic>
#include <expected>

namespace Aether::HAL {

    static constexpr size_t k_max_irqs = 256;

    using IrqHandler = std::function<void()>;
    using IrqFlags = uint32_t;

    enum class IrqPolicy : uint8_t {
        None,
        Acknowledge,
        MaskAndAck
    };

    struct IrqEntry {
        IrqHandler handler;
        IrqPolicy policy;
        bool enabled;
    };

    void outb(uint16_t port, uint8_t val) noexcept;
    uint8_t inb(uint16_t port) noexcept;
    void outw(uint16_t port, uint16_t val) noexcept;
    uint16_t inw(uint16_t port) noexcept;
    void outl(uint16_t port, uint32_t val) noexcept;
    uint32_t inl(uint16_t port) noexcept;

    void write32(Address addr, uint32_t val) noexcept;
    uint32_t read32(Address addr) noexcept;
    void write64(Address addr, uint64_t val) noexcept;
    uint64_t read64(Address addr) noexcept;

    void registerIrq(uint32_t irq, IrqHandler handler,
                     IrqPolicy policy = IrqPolicy::None) noexcept;

    void unregisterIrq(uint32_t irq) noexcept;

    void dispatchIrq(uint32_t irq) noexcept;

    void enableIrq(uint32_t irq) noexcept;
    void disableIrq(uint32_t irq) noexcept;
    bool isIrqEnabled(uint32_t irq) noexcept;

    struct DmaMapping {
        Address physical;
        size_t size;
    };

    std::expected<DmaMapping, ErrorCode> mapDma(Address virtual_addr, size_t size) noexcept;

    void halt() noexcept;

    void stop() noexcept;

    struct InterruptGuard {
        bool was_enabled;
        InterruptGuard() {
            was_enabled = true;
        }
        ~InterruptGuard() {
            if (!was_enabled) enableIrq(0);
        }
        void disable() { was_enabled = false; }
    };

} // namespace Aether::HAL
