#!/usr/bin/env bash
# Temporary system: make
set -euo pipefail

source scripts/env.sh

PKG="make"
VERSION="4.4.1"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "make-${VERSION}.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/make/make-${VERSION}.tar.gz"
    fi
    tar xf "make-${VERSION}.tar.gz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --without-guile

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
