# Aether

A from-scratch operating system. Custom kernel, toolchain, libc, init, userspace, and package manager.

## Stack

- **Kernel**: Linux 6.14 + CachyOS patches (EEVDF+sched-ext/LAVD, x86-64-v3, ThinLTO)
- **Toolchain**: Full LLVM/clang 22 — no GCC anywhere
- **libc**: llvm-libc (primary, first-class). glibc stage-1 only for bootstrap, then removed.
- **C++ std**: libc++/libc++abi exclusively (no libstdc++)
- **Linker**: lld (system default), mold (dev builds)
- **Init**: systemd now, custom `aether-init` later
- **Shell**: fish 4.7 (dash as POSIX sh fallback)
- **Coreutils**: uutils (Rust)
- **Alternatives**: ripgrep, fd, eza, bat
- **Package manager**: `apm` — custom C++ tool, binary `.aet` packages, source builds via `add-src`
- **Boot**: systemd-boot → UKI (unified kernel image, single `.efi` file)
- **Secure Boot**: Custom key management tool — enroll, sign, rotate, backup

## Build

```bash
source toolchain/env.sh
scripts/setup-dirs.sh

cmake -B build -G Ninja
ninja -C build toolchain-base    # Phase 1: cross-compiler toolchain
ninja -C build temporary-system  # Phase 2: temporary system
ninja -C build base-system       # Phase 3: base system (requires root)
```

## Branches

- `main` — Aether OS (this)
- `aether-kernel` — original micro-kernel experiment (preserved)

## License

OSL-3.0 © Veridian Zenith
