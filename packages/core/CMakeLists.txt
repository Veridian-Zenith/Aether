include("../cmake/PackageHelpers.cmake")

define_package(
    NAME        linux-kernel
    VERSION     6.14
    URL         https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz
    STAGE       base
    BUILD_SYSTEM make
    DEPENDS     glibc lld
    TOOLS       clang lld llvm-ar llvm-nm llvm-objcopy llvm-strip
)

define_package(
    NAME        systemd
    VERSION     261
    STAGE       base
    BUILD_SYSTEM meson
    DEPENDS     glibc libcap
)

define_package(
    NAME        fish
    VERSION     4.7.1
    STAGE       base
    BUILD_SYSTEM cmake
    DEPENDS     ncurses pcre2
)

define_package(
    NAME        uutils
    VERSION     0.0.29
    STAGE       base
    BUILD_SYSTEM cargo
    TOOLS       rust cargo
)

define_package(
    NAME        ripgrep
    VERSION     15.1.0
    STAGE       base
    BUILD_SYSTEM cargo
    TOOLS       rust cargo
)

define_package(
    NAME        fd
    VERSION     10.4.2
    STAGE       base
    BUILD_SYSTEM cargo
    TOOLS       rust cargo
)

define_package(
    NAME        eza
    VERSION     0.20.19
    STAGE       base
    BUILD_SYSTEM cargo
    TOOLS       rust cargo
)

define_package(
    NAME        bat
    VERSION     0.25.0
    STAGE       base
    BUILD_SYSTEM cargo
    TOOLS       rust cargo
)

define_package(
    NAME        mold
    VERSION     2.36.0
    STAGE       base
    BUILD_SYSTEM cmake
    DEPENDS     glibc
    TOOLS       clang lld
)
