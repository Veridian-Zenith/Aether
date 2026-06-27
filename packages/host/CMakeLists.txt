include("../cmake/PackageHelpers.cmake")

define_package(
    NAME        linux-headers
    VERSION     6.14
    URL         https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz
    STAGE       toolchain
    BUILD_SYSTEM make
)

define_package(
    NAME        glibc
    VERSION     2.41
    URL         https://ftp.gnu.org/gnu/glibc/glibc-2.41.tar.xz
    STAGE       toolchain
    BUILD_SYSTEM autotools
    DEPENDS     linux-headers
    TOOLS       clang lld
)

define_package(
    NAME        compiler-rt
    VERSION     22.1.6
    URL         https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.6/llvm-project-22.1.6.src.tar.xz
    STAGE       toolchain
    BUILD_SYSTEM cmake
    DEPENDS     glibc
    TOOLS       clang lld
)

define_package(
    NAME        libunwind
    VERSION     22.1.6
    STAGE       toolchain
    BUILD_SYSTEM cmake
    DEPENDS     compiler-rt
)

define_package(
    NAME        libcxxabi
    VERSION     22.1.6
    STAGE       toolchain
    BUILD_SYSTEM cmake
    DEPENDS     libunwind
)

define_package(
    NAME        libcxx
    VERSION     22.1.6
    STAGE       toolchain
    BUILD_SYSTEM cmake
    DEPENDS     libcxxabi
)

define_package(
    NAME        lld
    VERSION     22.1.6
    STAGE       toolchain
    BUILD_SYSTEM cmake
    DEPENDS     libcxx
)
