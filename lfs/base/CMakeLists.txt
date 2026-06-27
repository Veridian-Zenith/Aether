# ==== Phase 3: Base System ====
# Full system built inside chroot using the temporary tools

set(LFS_BASE_DIR "${PROJECT_SOURCE_DIR}/lfs/base")

function(add_base_pkg name script)
    add_custom_target("lfs-base-${name}"
        COMMAND sudo "${LFS_BASE_DIR}/${script}"
        COMMENT "Building ${name} (base system)"
        DEPENDS lfs-temporary
    )
endfunction()

# Core libraries and tools
add_base_pkg(man-pages     "build-man-pages.sh")
add_base_pkg(iana-etc      "build-iana-etc.sh")
add_base_pkg(glibc         "build-glibc.sh")
add_base_pkg(zlib          "build-zlib.sh")
add_base_pkg(bzip2         "build-bzip2.sh")
add_base_pkg(xz            "build-xz.sh")
add_base_pkg(zstd          "build-zstd.sh")
add_base_pkg(file          "build-file.sh")
add_base_pkg(readline      "build-readline.sh")
add_base_pkg(m4            "build-m4.sh")
add_base_pkg(bc            "build-bc.sh")
add_base_pkg(flex          "build-flex.sh")
add_base_pkg(libtool       "build-libtool.sh")
add_base_pkg(gmp           "build-gmp.sh")
add_base_pkg(mpfr          "build-mpfr.sh")
add_base_pkg(mpc           "build-mpc.sh")
add_base_pkg(gcc           "build-gcc.sh")

# System tools
add_base_pkg(sed           "build-sed.sh")
add_base_pkg(grep          "build-grep.sh")
add_base_pkg(bash          "build-bash.sh")
add_base_pkg(coreutils     "build-coreutils.sh")
add_base_pkg(diffutils     "build-diffutils.sh")
add_base_pkg(gawk          "build-gawk.sh")
add_base_pkg(findutils     "build-findutils.sh")
add_base_pkg(gzip          "build-gzip.sh")
add_base_pkg(make          "build-make.sh")
add_base_pkg(patch         "build-patch.sh")
add_base_pkg(tar           "build-tar.sh")
add_base_pkg(texinfo       "build-texinfo.sh")
add_base_pkg(vim           "build-vim.sh")

# Linux kernel
add_base_pkg(linux-kernel  "build-linux-kernel.sh")

# Network config
add_base_pkg(network       "build-network.sh")

# Bootloader
add_base_pkg(grub          "build-grub.sh")

# Aggregate target
add_custom_target(lfs-base
    COMMENT "Phase 3 complete: base system built"
)
add_dependencies(lfs-base lfs-base-grub lfs-base-network)
