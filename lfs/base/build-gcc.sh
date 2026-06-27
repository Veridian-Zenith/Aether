#!/usr/bin/env bash
# Base system: gcc — final native compiler
set -euo pipefail

source scripts/env.sh

PKG="gcc"
VERSION="14.2.0"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build-final"

echo "=== Building ${PKG}-${VERSION} (final) ==="

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --build="$(uname -m)-linux-gnu" \
    --host="${LFS_TGT}" \
    --target="${LFS_TGT}" \
    --with-build-sysroot="${LFS}/target" \
    --disable-nls \
    --enable-languages=c,c++ \
    --enable-shared \
    --enable-threads=posix \
    --enable-__cxa_atexit \
    --enable-clocale=generic \
    --enable-lto \
    --enable-linker-build-id \
    --enable-gnu-indirect-function \
    --enable-default-pie \
    --enable-default-ssp \
    --with-system-zlib \
    --with-isl

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Remove internal build headers
rm -fv "${LFS}/target/usr/lib/gcc/${LFS_TGT}/${VERSION}/include-fixed/limits.h"

echo "=== ${PKG}-${VERSION} final complete ==="
