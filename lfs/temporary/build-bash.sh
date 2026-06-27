#!/usr/bin/env bash
# Temporary system: bash
set -euo pipefail

source scripts/env.sh

PKG="bash"
VERSION="5.2.37"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "bash-${VERSION}.tar.gz" ]; then
        wget "https://ftp.gnu.org/gnu/bash/bash-${VERSION}.tar.gz"
    fi
    tar xf "bash-${VERSION}.tar.gz"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --without-bash-malloc \
    --with-installed-readline

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Create sh symlink
ln -sfv bash "${LFS}/target/bin/sh"

echo "=== ${PKG}-${VERSION} complete ==="
