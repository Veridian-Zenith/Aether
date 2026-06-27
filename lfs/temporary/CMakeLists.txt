# ==== Phase 2: Temporary System (chroot) ====
# Builds minimal toolchain inside chroot to bootstrap the base system

set(LFS_TEMP_DIR "${PROJECT_SOURCE_DIR}/lfs/temporary")
set(LFS_TOOLCHAIN_DIR "${PROJECT_SOURCE_DIR}/lfs/toolchain")

add_custom_target(lfs-chroot-env
    COMMAND sudo "${PROJECT_SOURCE_DIR}/scripts/setup-dirs.sh"
    COMMENT "Setting up chroot directory skeleton"
)

add_custom_target(lfs-temp-m4
    COMMAND "${LFS_TEMP_DIR}/build-m4.sh"
    COMMENT "Building m4 (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-ncurses
    COMMAND "${LFS_TEMP_DIR}/build-ncurses.sh"
    COMMENT "Building ncurses (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-bash
    COMMAND "${LFS_TEMP_DIR}/build-bash.sh"
    COMMENT "Building bash (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-coreutils
    COMMAND "${LFS_TEMP_DIR}/build-coreutils.sh"
    COMMENT "Building coreutils (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-gzip
    COMMAND "${LFS_TEMP_DIR}/build-gzip.sh"
    COMMENT "Building gzip (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-make
    COMMAND "${LFS_TEMP_DIR}/build-make.sh"
    COMMENT "Building make (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-sed
    COMMAND "${LFS_TEMP_DIR}/build-sed.sh"
    COMMENT "Building sed (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-tar
    COMMAND "${LFS_TEMP_DIR}/build-tar.sh"
    COMMENT "Building tar (temporary)"
    DEPENDS lfs-chroot-env
)

add_custom_target(lfs-temp-xz
    COMMAND "${LFS_TEMP_DIR}/build-xz.sh"
    COMMENT "Building xz (temporary)"
    DEPENDS lfs-chroot-env
)

# Aggregate target (builds everything above)
add_custom_target(lfs-temporary
    COMMENT "Phase 2 complete: temporary system built in chroot"
)
add_dependencies(lfs-temporary
    lfs-temp-m4
    lfs-temp-ncurses
    lfs-temp-bash
    lfs-temp-coreutils
    lfs-temp-gzip
    lfs-temp-make
    lfs-temp-sed
    lfs-temp-tar
    lfs-temp-xz
)
