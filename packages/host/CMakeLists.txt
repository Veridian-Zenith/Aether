# ==== Host Packages (for cross-compilation toolchain) ====
include("../cmake/PackageHelpers.cmake")

define_package(
    NAME        binutils
    VERSION     2.44
    URL         https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz
    STAGE       toolchain
)

define_package(
    NAME        gcc
    VERSION     14.2.0
    URL         https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
    STAGE       toolchain
    DEPENDS     binutils glibc
)

define_package(
    NAME        glibc
    VERSION     2.41
    URL         https://ftp.gnu.org/gnu/glibc/glibc-2.41.tar.xz
    STAGE       toolchain
    DEPENDS     linux-headers
)

define_package(
    NAME        linux-headers
    VERSION     6.14
    URL         https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz
    STAGE       toolchain
)
