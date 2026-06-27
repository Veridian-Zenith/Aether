# Building Aether Linux (LFS)

## Prerequisites

- Arch Linux (or any modern distro)
- Clang toolchain (host)
- CMake 3.18+, Ninja
- Root access for chroot operations
- ~10GB free disk space
- fast internet connection

## Quick Start

### 1. Set up environment

```bash
source scripts/env.sh
scripts/setup-dirs.sh
```

### 2. Build the cross-compiler toolchain (Phase 1)

```bash
cmake -B build -G Ninja
ninja -C build lfs-toolchain
```

This builds: binutils pass 1 → gcc pass 1 → linux headers → glibc → binutils pass 2 → gcc pass 2

### 3. Build the temporary system (Phase 2)

```bash
ninja -C build lfs-temporary
```

### 4. Build the base system (Phase 3)

```bash
sudo ninja -C build lfs-base
```

### 5. Configure the bootloader

```bash
# After installing to target disk:
sudo grub-install --boot-directory=/mnt/boot /dev/sda
```

## References

This project follows the [Linux From Scratch](https://www.linuxfromscratch.org/lfs/) book.
Each build script documents its corresponding LFS chapter.
