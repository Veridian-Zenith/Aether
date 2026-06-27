#!/usr/bin/env bash
# Phase 1: gcc pass 2 — full cross-compiler with libc support
set -euo pipefail

source scripts/env.sh

PKG="gcc"
VERSION="14.2.0"
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
    --disable-libsanitizer \
    --enable-languages=c,c++ \
    --enable-shared \
    --enable-threads=posix \
    --enable-__cxa_atexit \
    --enable-clocale=generic \
    --enable-lto \
    --enable-linker-build-id \
    --with-system-zlib

make -j$(nproc) all-gcc all-target-libgcc all-target-libstdc++-v3
make install-gcc install-target-libgcc install-target-libstdc++-v3

echo "=== ${PKG}-${VERSION} pass 2 complete ==="
