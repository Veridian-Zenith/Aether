#!/usr/bin/env bash
# Phase 1: gcc pass 1 — minimal cross-compiler (no libc yet)
set -euo pipefail

source scripts/env.sh

PKG="gcc"
VERSION="14.2.0"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build-pass1"

echo "=== Building ${PKG}-${VERSION} (pass 1) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "gcc-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.xz"
    fi
    tar xf "gcc-${VERSION}.tar.xz"
    cd "${SOURCE_DIR}"
    # Download prerequisites (mpfr, mpc, gmp, isl)
    ./contrib/download_prerequisites
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix="${LFS}/cross-tools" \
    --target="${LFS_TGT}" \
    --with-sysroot="${LFS}/target" \
    --disable-nls \
    --disable-libsanitizer \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libatomic \
    --disable-libvtv \
    --disable-libssp \
    --disable-threads \
    --enable-languages=c,c++ \
    --with-newlib \
    --without-headers

make -j$(nproc) all-gcc all-target-libgcc
make install-gcc install-target-libgcc

echo "=== ${PKG}-${VERSION} pass 1 complete ==="
