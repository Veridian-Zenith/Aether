/**
 * @file src/arch/x86_64/iommu_backend.cpp
 * @brief x86_64 implementation of IOMMU backend.
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "iommu.hpp"
#include <unordered_map>
#include "logger.hpp"
#include <format>

namespace Aether {

    class X86IommuBackend : public IommuBackend {
    private:
        std::unordered_map<ProcessId, std::unordered_map<Address, Address>> mappings_;

    public:
        [[nodiscard]] std::expected<void, ErrorCode> map_page(ProcessId pid, Address device_addr, Address physical_addr) noexcept override {
            auto& process_mappings = mappings_[pid];
            if (process_mappings.contains(device_addr)) {
                Aether::Log::record(Aether::Log::Level::Error, std::format("IOMMU: Mapping already exists for PID {}, DeviceAddr {:#x}", pid, device_addr));
                return std::unexpected(ErrorCode::InvalidSpell);
            }
            process_mappings[device_addr] = physical_addr;
            Aether::Log::record(Aether::Log::Level::Info, std::format("IOMMU: Mapped PID {}, DeviceAddr {:#x} -> PhysAddr {:#x}", pid, device_addr, physical_addr));
            return {};
        }

        [[nodiscard]] std::expected<void, ErrorCode> unmap_page(ProcessId pid, Address device_addr) noexcept override {
            if (!mappings_.contains(pid) || !mappings_[pid].contains(device_addr)) {
                Aether::Log::record(Aether::Log::Level::Error, std::format("IOMMU: Mapping doesn't exist for PID {}, DeviceAddr {:#x}", pid, device_addr));
                return std::unexpected(ErrorCode::RealmNotFound);
            }
            mappings_[pid].erase(device_addr);
            Aether::Log::record(Aether::Log::Level::Info, std::format("IOMMU: Unmapped PID {}, DeviceAddr {:#x}", pid, device_addr));
            return {};
        }

        [[nodiscard]] std::expected<void, ErrorCode> attach_device(ProcessId pid, uint32_t device_id) noexcept override {
            // Stub implementation
            return {};
        }
    };

    // Assuming a factory function to return the backend
    std::unique_ptr<IommuBackend> create_iommu_backend() {
        return std::make_unique<X86IommuBackend>();
    }

} // namespace Aether
