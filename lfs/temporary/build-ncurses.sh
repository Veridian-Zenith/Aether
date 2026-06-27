#!/usr/bin/env bash
# Temporary system: ncurses
set -euo pipefail

source scripts/env.sh

PKG="ncurses"
VERSION="6.5"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} (temporary) ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "ncurses-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/ncurses/ncurses-${VERSION}.tar.xz"
    fi
    tar xf "ncurses-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

# Build with dbg-gen so tic works
"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --with-shared \
    --without-debug \
    --without-ada \
    --enable-widec \
    --enable-database \
    --with-manpage-format=normal

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Create ncurses symlinks
ln -sfv libncursesw.so "${LFS}/target/usr/lib/libncurses.so"

echo "=== ${PKG}-${VERSION} complete ==="
