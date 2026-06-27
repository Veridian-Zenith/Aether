#!/usr/bin/env bash
# Temporary: ncurses (terminal handling, needed by fish)
set -euo pipefail
source toolchain/env.sh

PKG="ncurses"
VERSION="6.5"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://ftp.gnu.org/gnu/ncurses/ncurses-${VERSION}.tar.xz"
    tar xf "ncurses-${VERSION}.tar.xz"
}

cd "${SDIR}"
CC=clang \
CFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2" \
LDFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -fuse-ld=lld" \
./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --with-shared \
    --without-debug \
    --without-ada \
    --enable-widec

make -j$(nproc)
make DESTDIR="${LFS}/target" install
ln -sfv libncursesw.so "${LFS}/target/usr/lib/libncurses.so"

echo "=== ncurses ${VERSION} complete ==="
