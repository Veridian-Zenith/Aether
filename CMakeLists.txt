cmake_minimum_required(VERSION 3.18)

# ---- Ignore External Flags ----
set(ENV{CFLAGS} "")
set(ENV{CXXFLAGS} "")
set(ENV{LDFLAGS} "")
set(CMAKE_C_FLAGS "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "" CACHE STRING "" FORCE)

project(Aether VERSION 1.0.0 LANGUAGES CXX)

# ---- Cache Acceleration ----
if(NOT DEFINED ENV{CCACHE_DISABLE})
    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        message(STATUS "ccache found: ${CCACHE_PROGRAM}")
        set(CMAKE_C_COMPILER_LAUNCHER   "${CCACHE_PROGRAM}")
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    endif()
endif()

# ---- Formal Verification Pipeline ----
find_program(CLANG_TIDY_EXE NAMES clang-tidy)
if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE};--extra-arg=-std=c++26")
    message(STATUS "clang-tidy enabled for formal verification.")
endif()

option(AETHER_ENABLE_SECCOMP "Enable Seccomp syscall filtering" ON)

# Enable hardening flags
add_compile_options("-fstack-protector-strong" "-D_FORTIFY_SOURCE=3" "-fPIE" "-fstack-clash-protection")
add_link_options("-Wl,-z,relro" "-Wl,-z,now" "-Wl,-z,noexecstack")

# ---- Toolchain Validation ----
if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(FATAL_ERROR "Clang compiler is required. Found: ${CMAKE_CXX_COMPILER_ID}")
endif()

# ---- Compiler & Feature Flags ----
set(COMMON_FLAGS "-Oz -pipe -fno-plt -fstack-protector-strong \
-fstack-clash-protection -D_FORTIFY_SOURCE=3 -fPIE -flto=thin -fvisibility=hidden \
-fexperimental-library -std=c++26")

set(DEBUG_FLAGS "-g -fstandalone-debug -fno-omit-frame-pointer")
set(RELEASE_FLAGS "-O3 -DNDEBUG")

set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${DEBUG_FLAGS}" CACHE STRING "" FORCE)
string(APPEND CMAKE_CXX_FLAGS_DEBUG " ${COMMON_FLAGS} ${DEBUG_FLAGS}")
string(APPEND CMAKE_CXX_FLAGS_RELEASE " ${COMMON_FLAGS} ${RELEASE_FLAGS}")

# ---- Linker Flags ----
set(LINKER_FLAGS "-Wl,-O3 -Wl,--as-needed -Wl,-z,relro -Wl,-z,now \
-Wl,-z,noexecstack -Wl,--icf=all \
-pie -flto=thin")

if(AETHER_USE_MOLD)
    set(LINKER_FLAGS "-fuse-ld=mold ${LINKER_FLAGS}")
else()
    set(LINKER_FLAGS "-fuse-ld=lld ${LINKER_FLAGS}")
endif()

set(CMAKE_EXE_LINKER_FLAGS "" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${LINKER_FLAGS} -Wl,--strip-all" CACHE STRING "" FORCE)

# ---- Source & Executable ----
file(GLOB_RECURSE AETHER_SOURCES src/*.cpp)
list(REMOVE_ITEM AETHER_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")

add_library(aether_lib STATIC ${AETHER_SOURCES})
target_include_directories(aether_lib PUBLIC include)

if(AETHER_ENABLE_SECCOMP)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBSECCOMP REQUIRED libseccomp)
    target_link_libraries(aether_lib PUBLIC ${LIBSECCOMP_LIBRARIES})
    target_compile_definitions(aether_lib PUBLIC AETHER_WITH_SECCOMP)
endif()

add_executable(aether src/main.cpp)
target_link_libraries(aether PRIVATE aether_lib)

target_compile_options(aether_lib PRIVATE -Wall -Wextra)
target_compile_options(aether PRIVATE -Wall -Wextra)

# ---- Testing Logic ----
if(NOT DEFINED BUILD_TESTING)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(BUILD_TESTING ON CACHE BOOL "Build tests" FORCE)
    else()
        set(BUILD_TESTING OFF CACHE BOOL "Build tests" FORCE)
    endif()
endif()

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
    add_dependencies(aether run_tests)
endif()
