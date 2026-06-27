#!/usr/bin/env bash
# LFS environment — source this before building
# Usage: source scripts/env.sh

export LFS="${LFS:-$(realpath rootfs)}"
export LFS_TGT="x86_64-linux-gnu"

# Number of parallel jobs for make
export MAKEFLAGS="-j$(nproc)"

# Cross-compiler path
export PATH="${LFS}/cross-tools/bin:${PATH}"

# Prevent bogus ownership warnings in chroot
export LFS_ROOT="${LFS}/target"

echo "LFS root:   ${LFS}"
echo "Target:     ${LFS_TGT}"
echo "Make flags: ${MAKEFLAGS}"
echo "Cross-bin:  ${LFS}/cross-tools/bin"
