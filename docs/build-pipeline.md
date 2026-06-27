# Build Guide

## Prerequisites

- Arch Linux (or any modern Linux)
- Clang/LLVM 22 (host)
- CMake 3.18+, Ninja
- Rust toolchain (for uutils, ripgrep, fd, eza, bat)
- wget, git
- Root access for chroot operations
- ~20GB free disk

## Build Pipeline

```
Phase 1: Toolchain                    Phase 2: Temporary              Phase 3: Base
┌──────────────────────┐              ┌────────────────────┐          ┌────────────────────┐
│ linux-headers        │              │ dash               │          │ kernel (CachyOS)   │
│ glibc                │              │ m4                 │          │ systemd            │
│ compiler-rt          │  ──────────► │ ncurses            │  ──────► │ fish               │
│ libunwind            │  make install│ uutils (Rust)      │  chroot  │ ripgrep, fd, eza   │
│ libc++abi            │  to sysroot  │ mold               │          │ network, bootloader│
│ libc++               │              │ fish               │          │ config             │
│ lld                  │              └────────────────────┘          └────────────────────┘
└──────────────────────┘
```

## Stage Commands

```bash
# Phase 1 — cross-compile LLVM toolchain
ninja -C build toolchain-base

# Phase 2 — build temporary tools into sysroot
ninja -C build temporary-system

# Phase 3 — build final bootable system (in chroot)
sudo ninja -C build base-system
```
