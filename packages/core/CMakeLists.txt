# ==== Core Packages (base system) ====
include("../cmake/PackageHelpers.cmake")

define_package(
    NAME        linux
    VERSION     6.14
    URL         https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz
    STAGE       base
    DEPENDS     glibc
)

define_package(
    NAME        gcc-final
    VERSION     14.2.0
    URL         https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
    STAGE       base
    DEPENDS     glibc m4
)

define_package(
    NAME        bash
    VERSION     5.2.37
    URL         https://ftp.gnu.org/gnu/bash/bash-5.2.37.tar.gz
    STAGE       base
    DEPENDS     ncurses readline
)

define_package(
    NAME        coreutils
    VERSION     9.6
    URL         https://ftp.gnu.org/gnu/coreutils/coreutils-9.6.tar.xz
    STAGE       base
)

define_package(
    NAME        grub
    VERSION     2.12
    URL         https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
    STAGE       base
)
