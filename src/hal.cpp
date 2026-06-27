#include "hal.hpp"
#include "logger.hpp"
#include <format>
#include <array>
#include <mutex>

namespace Aether::HAL {

    namespace {
        std::array<IrqEntry, k_max_irqs> s_irq_table{};
        std::mutex s_irq_mutex;
    }

    void outb(uint16_t port, uint8_t val) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("outb %0, %1" : : "a"(val), "Nd"(port));
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Writing {:#x} to port {:#x}", val, port));
#endif
    }

    uint8_t inb(uint16_t port) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        uint8_t val;
        __asm__ volatile("inb %1, %0" : "=a"(val) : "Nd"(port));
        return val;
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Reading from port {:#x}", port));
        return 0;
#endif
    }

    void outw(uint16_t port, uint16_t val) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("outw %0, %1" : : "a"(val), "Nd"(port));
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Writing word {:#x} to port {:#x}", val, port));
#endif
    }

    uint16_t inw(uint16_t port) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        uint16_t val;
        __asm__ volatile("inw %1, %0" : "=a"(val) : "Nd"(port));
        return val;
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Reading word from port {:#x}", port));
        return 0;
#endif
    }

    void outl(uint16_t port, uint32_t val) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("outl %0, %1" : : "a"(val), "Nd"(port));
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Writing dword {:#x} to port {:#x}", val, port));
#endif
    }

    uint32_t inl(uint16_t port) noexcept {
#if defined(__x86_64__) || defined(__i386__)
        uint32_t val;
        __asm__ volatile("inl %1, %0" : "=a"(val) : "Nd"(port));
        return val;
#else
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Reading dword from port {:#x}", port));
        return 0;
#endif
    }

    void write32(Address addr, uint32_t val) noexcept {
        *reinterpret_cast<volatile uint32_t*>(addr) = val;
    }

    uint32_t read32(Address addr) noexcept {
        return *reinterpret_cast<volatile uint32_t*>(addr);
    }

    void write64(Address addr, uint64_t val) noexcept {
        *reinterpret_cast<volatile uint64_t*>(addr) = val;
    }

    uint64_t read64(Address addr) noexcept {
        return *reinterpret_cast<volatile uint64_t*>(addr);
    }

    void registerIrq(uint32_t irq, IrqHandler handler, IrqPolicy policy) noexcept {
        if (irq >= k_max_irqs) {
            Aether::Log::record(Aether::Log::Level::Error,
                std::format("HAL: IRQ {} out of range", irq));
            return;
        }
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        s_irq_table[irq] = IrqEntry{std::move(handler), policy, true};
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Registered handler for IRQ {}", irq));
    }

    void unregisterIrq(uint32_t irq) noexcept {
        if (irq >= k_max_irqs) return;
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        s_irq_table[irq] = IrqEntry{nullptr, IrqPolicy::None, false};
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Unregistered handler for IRQ {}", irq));
    }

    void dispatchIrq(uint32_t irq) noexcept {
        if (irq >= k_max_irqs) return;
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        auto& entry = s_irq_table[irq];
        if (entry.handler && entry.enabled) {
            entry.handler();
        }
    }

    void enableIrq(uint32_t irq) noexcept {
        if (irq >= k_max_irqs) return;
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        s_irq_table[irq].enabled = true;
    }

    void disableIrq(uint32_t irq) noexcept {
        if (irq >= k_max_irqs) return;
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        s_irq_table[irq].enabled = false;
    }

    bool isIrqEnabled(uint32_t irq) noexcept {
        if (irq >= k_max_irqs) return false;
        std::lock_guard<std::mutex> lock(s_irq_mutex);
        return s_irq_table[irq].enabled;
    }

    std::expected<DmaMapping, ErrorCode> mapDma(Address virtual_addr, size_t size) noexcept {
        Aether::Log::record(Aether::Log::Level::Info,
            std::format("HAL: Mapping DMA for VAddr {:#x} size {}", virtual_addr, size));
        return DmaMapping{virtual_addr, size};
    }

    void halt() noexcept {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("hlt");
#else
        Aether::Log::record(Aether::Log::Level::Info, "HAL: HALT instruction");
#endif
    }

    void stop() noexcept {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("cli; hlt");
#else
        Aether::Log::record(Aether::Log::Level::Info, "HAL: STOP (cli; hlt)");
#endif
    }

} // namespace Aether::HAL
