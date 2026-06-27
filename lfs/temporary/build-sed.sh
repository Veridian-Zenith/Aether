#!/usr/bin/env bash
# Temporary system: sed
set -euo pipefail

source scripts/env.sh

PKG="sed"
VERSION="4.9"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "sed-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/sed/sed-${VERSION}.tar.xz"
    fi
    tar xf "sed-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu"

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
