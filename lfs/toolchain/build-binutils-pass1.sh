#!/usr/bin/env bash
# Phase 1: binutils pass 1 — minimal cross-assembler/linker
set -euo pipefail

source scripts/env.sh

PKG="binutils"
VERSION="2.44"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build-pass1"

echo "=== Building ${PKG}-${VERSION} (pass 1) ==="

# Download if needed
mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "binutils-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/binutils/binutils-${VERSION}.tar.xz"
    fi
    tar xf "binutils-${VERSION}.tar.xz"
fi

# Build
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
    --enable-64-bit-bfd

make -j$(nproc)
make install

echo "=== ${PKG}-${VERSION} pass 1 complete ==="
