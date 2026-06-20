#include "logger.hpp"
#include <chrono>
#include <iostream>

void Aether::Log::record(Level level, std::string_view message) noexcept {
    auto now = std::chrono::system_clock::now();
    std::print("[{:%H:%M:%S}] ", now);
    switch(level) {
        case Level::Info: std::print("[INFO] "); break;
        case Level::Warning: std::print("[WARN] "); break;
        case Level::Error: std::print("[ERR] "); break;
    }
    std::println("{}", message);
}
