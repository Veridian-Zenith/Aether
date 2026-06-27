#!/usr/bin/env bash
# Temporary system: xz-utils
set -euo pipefail

source scripts/env.sh

PKG="xz"
VERSION="5.6.4"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "xz-${VERSION}.tar.xz" ]; then
        wget "https://github.com/tukaani-project/xz/releases/download/v${VERSION}/xz-${VERSION}.tar.xz"
    fi
    tar xf "xz-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --disable-static

make -j$(nproc)
make DESTDIR="${LFS}/target" install

echo "=== ${PKG}-${VERSION} complete ==="
