# ==== Phase 1: Cross-Compiler Toolchain ====
# Builds binutils + gcc + linux headers + glibc for the target

set(LFS_TOOLCHAIN_DIR "${PROJECT_SOURCE_DIR}/lfs/toolchain")

# ----- Step 1: binutils pass 1 -----
set(BINUTILS_VERSION "2.44")
set(BINUTILS_URL "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz")

add_custom_target(binutils-pass1
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-binutils-pass1.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building binutils-${BINUTILS_VERSION} (pass 1)"
)

# ----- Step 2: gcc pass 1 -----
set(GCC_VERSION "14.2.0")
set(GCC_URL "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz")

add_custom_target(gcc-pass1
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-gcc-pass1.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building gcc-${GCC_VERSION} (pass 1)"
)
add_dependencies(gcc-pass1 binutils-pass1)

# ----- Step 3: Linux kernel headers -----
set(LINUX_VERSION "6.14")
set(LINUX_VERSION_FULL "${LINUX_VERSION}")
set(LINUX_URL "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${LINUX_VERSION_FULL}.tar.xz")

add_custom_target(linux-headers
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-linux-headers.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Installing Linux ${LINUX_VERSION} headers"
)

# ----- Step 4: glibc -----
set(GLIB_VERSION "2.41")
set(GLIB_URL "https://ftp.gnu.org/gnu/glibc/glibc-${GLIB_VERSION}.tar.xz")

add_custom_target(glibc
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-glibc.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building glibc-${GLIB_VERSION}"
)
add_dependencies(glibc binutils-pass1 gcc-pass1 linux-headers)

# ----- Step 5: binutils pass 2 -----
add_custom_target(binutils-pass2
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-binutils-pass2.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building binutils-${BINUTILS_VERSION} (pass 2)"
)
add_dependencies(binutils-pass2 glibc)

# ----- Step 6: gcc pass 2 -----
add_custom_target(gcc-pass2
    COMMAND "${LFS_TOOLCHAIN_DIR}/build-gcc-pass2.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building gcc-${GCC_VERSION} (pass 2)"
)
add_dependencies(gcc-pass2 binutils-pass2)

# ----- Aggregate target -----
add_custom_target(lfs-toolchain
    COMMENT "Phase 1 complete: cross-compiler toolchain built"
)
add_dependencies(lfs-toolchain gcc-pass2)
