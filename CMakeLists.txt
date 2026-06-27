cmake_minimum_required(VERSION 3.18)
project(AetherLinux VERSION 1.0.0 LANGUAGES C CXX)

# ==== Options ====
set(AETHER_TARGET "x86_64-linux-gnu" CACHE STRING "Target triplet")
set(AETHER_ROOT "${CMAKE_SOURCE_DIR}/rootfs" CACHE PATH "Root filesystem output directory")
set(AETHER_SOURCES_DIR "${CMAKE_SOURCE_DIR}/packages/sources" CACHE PATH "Downloaded package sources")
set(AETHER_PARALLEL "$(nproc)" CACHE STRING "Parallel build jobs")

# ==== Build Pipeline Stages ====
add_subdirectory(lfs/toolchain)
add_subdirectory(lfs/temporary)
add_subdirectory(lfs/base)

# ==== Convenience Alias ====
add_custom_target(lfs-all)
add_dependencies(lfs-all lfs-toolchain lfs-temporary lfs-base)

message(STATUS "Aether Linux — LFS Build System")
message(STATUS "  Target:            ${AETHER_TARGET}")
message(STATUS "  Root filesystem:   ${AETHER_ROOT}")
message(STATUS "  Source cache:      ${AETHER_SOURCES_DIR}")
message(STATUS "  Parallel jobs:     ${AETHER_PARALLEL}")
