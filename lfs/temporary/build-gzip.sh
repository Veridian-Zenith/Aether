#!/usr/bin/env bash
# Temporary system: gzip
set -euo pipefail

source scripts/env.sh

PKG="gzip"
VERSION="1.13"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "gzip-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/gzip/gzip-${VERSION}.tar.xz"
    fi
    tar xf "gzip-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu"

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
