#!/usr/bin/env bash
# Phase 1: binutils pass 2 — full cross-binutils against target libc
set -euo pipefail

source scripts/env.sh

PKG="binutils"
VERSION="2.44"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build-pass2"

echo "=== Building ${PKG}-${VERSION} (pass 2) ==="

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix="${LFS}/cross-tools" \
    --target="${LFS_TGT}" \
    --with-sysroot="${LFS}/target" \
    --disable-nls \
    --disable-werror \
    --enable-deterministic-archives \
    --enable-shared \
    --enable-64-bit-bfd \
    --enable-gold=yes \
    --enable-plugins

make -j$(nproc)
make install

echo "=== ${PKG}-${VERSION} pass 2 complete ==="
