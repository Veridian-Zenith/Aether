/**
 * @file src/iommu.cpp
 * @brief Implementation structure for IOMMU management.
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "iommu.hpp"
#include <memory>

namespace Aether {

    // Forward declaration of backend factory
    std::unique_ptr<IommuBackend> create_iommu_backend();

    IommuManager& IommuManager::instance() {
        static IommuManager instance(create_iommu_backend());
        return instance;
    }

} // namespace Aether
