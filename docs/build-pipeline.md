# Build Pipeline

Aether is built in three phases. Each phase produces the inputs for the next.

```
Phase 1: Toolchain                    Phase 2: Temporary              Phase 3: Base
┌──────────────────────┐              ┌────────────────────┐          ┌────────────────────┐
│ linux-headers        │              │ dash               │          │ kernel (CachyOS)   │
│ compiler-rt          │              │ m4                 │          │ systemd            │
│ llvm-libc            │  ──────────► │ ncurses            │  ──────► │ fish               │
│ libunwind            │  install to  │ uutils (Rust)      │  root     │ iwd                │
│ libc++abi            │  sysroot     │ mold               │  context  │ ripgrep, fd, eza   │
│ libc++               │              │ fish               │           │ apm                │
│ lld                  │              └────────────────────┘          │ network, bootloader│
└──────────────────────┘                                              │ system config      │
                                                                      └────────────────────┘
```

## Phase 1: Cross-Compiler Toolchain

Builds the LLVM toolchain for the target architecture. Everything is cross-compiled with the host's clang. No GCC or glibc in the output.

Output installed to `rootfs/cross-tools/` and `rootfs/target/`.

## Phase 2: Temporary System

Minimal userspace built against the cross-toolchain. Enough to run a shell and basic tools inside a root context. These are temporary — used only to build Phase 3.

## Phase 3: Base System

The final bootable system. Built inside a root context using the temporary tools. Produces the kernel, init, drivers, networking, and package manager.

## Package Manager Takeover

After Phase 3, `apm` (Aether Package Manager) is installed and takes over all future package management. The build scripts are retired.
