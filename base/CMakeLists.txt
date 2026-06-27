# ==== Phase 3: Base System ====
# Full bootable system

set(BASE "${PROJECT_SOURCE_DIR}/base")

function(base_pkg name)
    add_custom_target("base-${name}"
        COMMAND sudo "${BASE}/scripts/${name}.sh"
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        COMMENT "Building ${name} (base system)"
        DEPENDS temporary-system
    )
endfunction()

base_pkg(readline)
base_pkg(zlib)
base_pkg(bzip2)
base_pkg(xz)
base_pkg(zstd)
base_pkg(file)
base_pkg(bc)
base_pkg(flex)
base_pkg(pkgconf)
base_pkg(libtool)
base_pkg(gmp)
base_pkg(mpfr)
base_pkg(mpc)
base_pkg(iana-etc)

# LLVM for target (clang, libclang, etc.)
add_custom_target(base-llvm
    COMMAND "${BASE}/scripts/llvm.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM/clang for target"
    DEPENDS temporary-system
)

# CachyOS kernel
add_custom_target(base-kernel
    COMMAND "${BASE}/scripts/kernel.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building CachyOS-patched kernel"
    DEPENDS base-llvm
)

# iwd — WiFi (before systemd so networking works early)
base_pkg(iwd)

# systemd
add_custom_target(base-systemd
    COMMAND sudo "${BASE}/scripts/systemd.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building systemd"
    DEPENDS base-kernel base-iwd
)

# Final configuration
add_custom_target(base-config
    COMMAND "${BASE}/scripts/config-system.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Configuring system (fish, fstab, hosts, bootloader, iwd)"
    DEPENDS base-systemd
)

add_custom_target(base-system
    COMMENT "Phase 3 complete: Aether Linux base ready"
)
add_dependencies(base-system base-config)

# Additional modern tools
base_pkg(rg)
base_pkg(fd)
base_pkg(eza)
base_pkg(bat)
