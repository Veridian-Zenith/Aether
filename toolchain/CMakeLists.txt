# ==== Phase 1: LLVM Cross-Compiler Toolchain ====
# Uses host clang to cross-compile for the target
# No GCC anywhere in the pipeline
# No glibc in final system — llvm-libc is the system libc
#
# Bootstrap order:
#   linux-headers → compiler-rt → llvm-libc → libunwind → libc++abi → libc++ → lld
#
# If llvm-libc is missing features needed by libunwind/libc++,
# the optional 02-glibc-stage1.sh step inserts a temporary glibc.

set(TC "${PROJECT_SOURCE_DIR}/toolchain")

add_custom_target(tc-linux-headers
    COMMAND "${TC}/scripts/01-linux-headers.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Installing Linux 6.14 headers"
)

add_custom_target(tc-compiler-rt
    COMMAND "${TC}/scripts/02-compiler-rt.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM compiler-rt builtins for target"
    DEPENDS tc-linux-headers
)

add_custom_target(tc-llvm-libc
    COMMAND "${TC}/scripts/03-llvm-libc.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building llvm-libc (primary C library)"
    DEPENDS tc-compiler-rt
)

add_custom_target(tc-libunwind
    COMMAND "${TC}/scripts/04-libunwind.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM libunwind for target"
    DEPENDS tc-llvm-libc
)

add_custom_target(tc-libcxxabi
    COMMAND "${TC}/scripts/05-libcxxabi.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM libc++abi for target"
    DEPENDS tc-libunwind
)

add_custom_target(tc-libcxx
    COMMAND "${TC}/scripts/06-libcxx.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM libc++ for target"
    DEPENDS tc-libcxxabi
)

add_custom_target(tc-lld
    COMMAND "${TC}/scripts/07-lld.sh"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Building LLVM lld for target"
    DEPENDS tc-libcxx
)

add_custom_target(toolchain-base
    COMMENT "Phase 1 complete: LLVM toolchain (no glibc)"
)
add_dependencies(toolchain-base tc-lld)
