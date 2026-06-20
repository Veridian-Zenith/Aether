/**
 * @file logger.hpp
 * @brief Production-grade logging facility
 */
#pragma once
#include <string_view>
#include <print>

namespace Aether::Log {
    enum class Level { Info, Warning, Error };
    void record(Level level, std::string_view message) noexcept;
}
