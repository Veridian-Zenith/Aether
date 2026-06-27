#!/usr/bin/env bash
# Temporary system: tar
set -euo pipefail

source scripts/env.sh

PKG="tar"
VERSION="1.35"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "tar-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/tar/tar-${VERSION}.tar.xz"
    fi
    tar xf "tar-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu"

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
