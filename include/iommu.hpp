/**
 * @file include/iommu.hpp
 * @brief Hardware-enforced memory management interface for IOMMUs.
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "kernel.hpp"
#include <expected>
#include <cstdint>
#include <memory>

namespace Aether {

    /**
     * @brief Abstract interface for IOMMU hardware backend.
     */
    class IommuBackend {
    public:
        virtual ~IommuBackend() = default;

        [[nodiscard]] virtual std::expected<void, ErrorCode> map_page(ProcessId pid, Address device_addr, Address physical_addr) noexcept = 0;
        [[nodiscard]] virtual std::expected<void, ErrorCode> unmap_page(ProcessId pid, Address device_addr) noexcept = 0;
        [[nodiscard]] virtual std::expected<void, ErrorCode> attach_device(ProcessId pid, uint32_t device_id) noexcept = 0;
    };

    /**
     * @brief Manages IOMMU hardware to enforce memory isolation for devices.
     */
    class IommuManager {
    public:
        static IommuManager& instance();

        IommuManager(std::unique_ptr<IommuBackend> backend) : backend_(std::move(backend)) {}

        [[nodiscard]] std::expected<void, ErrorCode> map_page(ProcessId pid, Address device_addr, Address physical_addr) noexcept {
            return backend_->map_page(pid, device_addr, physical_addr);
        }

        [[nodiscard]] std::expected<void, ErrorCode> unmap_page(ProcessId pid, Address device_addr) noexcept {
            return backend_->unmap_page(pid, device_addr);
        }

        [[nodiscard]] std::expected<void, ErrorCode> attach_device(ProcessId pid, uint32_t device_id) noexcept {
            return backend_->attach_device(pid, device_id);
        }

    private:
        std::unique_ptr<IommuBackend> backend_;
    };

} // namespace Aether
