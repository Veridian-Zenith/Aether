#!/usr/bin/env bash
# Temporary system: coreutils
set -euo pipefail

source scripts/env.sh

PKG="coreutils"
VERSION="9.6"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "coreutils-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${VERSION}.tar.xz"
    fi
    tar xf "coreutils-${VERSION}.tar.xz"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --enable-no-install-program=kill,uptime \
    --enable-install-program=hostname

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Move programs to proper locations
mv -v "${LFS}/target/usr/bin/chroot" "${LFS}/target/usr/sbin"

echo "=== ${PKG}-${VERSION} complete ==="
