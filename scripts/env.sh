#!/usr/bin/env fish
# Source this in fish: source scripts/env.fish
set -gx LFS (realpath rootfs)
set -gx LFS_TGT x86_64-linux-gnu
set -gx MAKEFLAGS "-j"(nproc)
set -gx PATH "$LFS/cross-tools/bin" $PATH

echo "LFS: $LFS"
echo "Target: $LFS_TGT"
