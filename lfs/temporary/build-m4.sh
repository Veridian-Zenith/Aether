#!/usr/bin/env bash
# Temporary system: m4
set -euo pipefail

source scripts/env.sh

PKG="m4"
VERSION="1.4.19"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "m4-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/m4/m4-${VERSION}.tar.xz"
    fi
    tar xf "m4-${VERSION}.tar.xz"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu"

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
