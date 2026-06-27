# ==== Phase 2: Temporary System ====
# Minimal tools built into chroot using cross-compiler

set(TMP "${PROJECT_SOURCE_DIR}/temporary")

function(tmp_pkg name)
    add_custom_target("tmp-${name}"
        COMMAND "${TMP}/scripts/${name}.sh"
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        COMMENT "Building ${name} (temporary)"
        DEPENDS toolchain-base
    )
endfunction()

tmp_pkg(dash)
tmp_pkg(m4)
tmp_pkg(ncurses)
tmp_pkg(uutils)
tmp_pkg(mold)

# Built inside chroot (need a POSIX sh first)
add_custom_target(tmp-fish
    COMMAND "${TMP}/scripts/fish.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building fish (temporary)"
    DEPENDS tmp-dash tmp-m4 tmp-ncurses
)

add_custom_target(temporary-system
    COMMENT "Phase 2 complete: temporary system ready"
)
add_dependencies(temporary-system tmp-mold tmp-fish)
