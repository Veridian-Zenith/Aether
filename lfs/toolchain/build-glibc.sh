#!/usr/bin/env bash
# Phase 1: glibc — cross-compiled C library
set -euo pipefail

source scripts/env.sh

PKG="glibc"
VERSION="2.41"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"
BUILD_DIR="${SOURCE_DIR}/build"

echo "=== Building ${PKG}-${VERSION} ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "glibc-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/glibc/glibc-${VERSION}.tar.xz"
    fi
    tar xf "glibc-${VERSION}.tar.xz"
fi

# Apply LFS-recommended fix for libgcc_s
cd "${SOURCE_DIR}"
if [ -f "../glibc-${VERSION}-libgcc_eh-1.patch" ]; then
    patch -Np1 < "../glibc-${VERSION}-libgcc_eh-1.patch"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "libc_cv_slibdir=/usr/lib" >> config.cache

"${SOURCE_DIR}/configure" \
    --prefix=/usr \
    --build="$(uname -m)-linux-gnu" \
    --host="${LFS_TGT}" \
    --target="${LFS_TGT}" \
    --with-headers="${LFS}/target/usr/include" \
    --cache-file=config.cache \
    --disable-nls \
    --enable-kernel=6.2 \
    --disable-profile \
    --enable-stack-protector=strong \
    --enable-bind-now

make -j$(nproc)
make install_root="${LFS}/target" install

# Fix absolute symlinks
sed -n '/REENTRANT/,/^$/p' "${SOURCE_DIR}/nptl/sysdeps/pthread/configure" | \
    sed 's/def SYSCALL_SIGSET_T_PTR/undef SYSCALL_SIGSET_T_PTR/' > /dev/null

echo "=== ${PKG}-${VERSION} complete ==="
