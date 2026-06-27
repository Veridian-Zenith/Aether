# Aether Linux

A Linux From Scratch distribution built with CMake orchestration.

## Project Structure

```
lfs/          — Build pipeline: toolchain → temporary tools → base system
packages/     — Package definitions with version/url/build-metadata
config/       — Kernel configs, system files, bootloader config
rootfs/       — Build output (cross-tools + target root filesystem)
scripts/      — Build orchestration and utility scripts
```

## Prerequisites

- Linux host (tested on Arch Linux)
- CMake 3.18+
- Ninja
- 10GB+ free disk
- Root access for chroot operations

## Build

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
ninja -C build lfs-toolchain   # Phase 1: cross-compiler
ninja -C build lfs-temporary   # Phase 2: temporary system
ninja -C build lfs-base        # Phase 3: base system (requires root)
```

The kernel from `aether-kernel` branch will be integrated in a future release.
