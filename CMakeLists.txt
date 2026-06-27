cmake_minimum_required(VERSION 3.18)
project(AetherLinux VERSION 1.0.0 LANGUAGES C CXX)

set(AETHER_TARGET "x86_64-linux-gnu" CACHE STRING "Target triplet")
set(AETHER_ROOT "${CMAKE_SOURCE_DIR}/rootfs" CACHE PATH "Root filesystem")
set(AETHER_SRC "${CMAKE_SOURCE_DIR}/packages/sources" CACHE PATH "Package source cache")

# ==== Build Pipeline ====
add_subdirectory(toolchain)
add_subdirectory(temporary)
add_subdirectory(base)

add_custom_target(aether-all)
add_dependencies(aether-all toolchain-base)

message(STATUS "Aether Linux — LLVM-based LFS Build")
message(STATUS "  Target:   ${AETHER_TARGET}")
message(STATUS "  Root:     ${AETHER_ROOT}")
message(STATUS "  Sources:  ${AETHER_SRC}")
