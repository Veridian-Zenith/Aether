# Aether Linux

A performance-optimised Linux distribution built from scratch, following the LFS methodology.

## Stack

- **Kernel**: Linux 6.14 + CachyOS patches (EEVDF/BORE scheduler, x86-64-v3, LTO)
- **Compiler**: Full LLVM/clang 22 — no GCC
- **Linker**: mold (host) / lld (system)
- **libc**: glibc 2.41
- **Init**: systemd
- **Shell**: fish 4.7 (dash as POSIX sh fallback)
- **Coreutils**: uutils (Rust rewrite)
- **Alternatives**: ripgrep, fd, eza, bat, bsdtar

## Quick Start

```bash
# Source LLVM cross-compilation environment
source toolchain/env.sh

# Create directory skeleton
scripts/setup-dirs.sh

# Phase 1: Cross-compiler toolchain (LLVM-based)
cmake -B build -G Ninja && ninja -C build toolchain-base

# Phase 2: Temporary system
ninja -C build temporary-system

# Phase 3: Base system (requires root)
sudo ninja -C build base-system
```

## Legacy

The original Aether micro-kernel lives on the `aether-kernel` branch.
