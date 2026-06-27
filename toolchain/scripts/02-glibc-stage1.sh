#!/usr/bin/env bash
# glibc stage 1 — OPTIONAL fallback for llvm-libc bootstrap
# Only use this if llvm-libc is missing features that libunwind/libc++ need.
# In the clean bootstrap path, this script is skipped entirely.
#
# If used: glibc is built, llvm-libc is built against it, then glibc is removed.
set -euo pipefail
source toolchain/env.sh

PKG="glibc"
VERSION="2.41"
SDIR="${LFS_SRC}/${PKG}-${VERSION}"
BDIR="${SDIR}/build"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://ftp.gnu.org/gnu/glibc/glibc-${VERSION}.tar.xz"
    tar xf "glibc-${VERSION}.tar.xz"
}

# glibc requires CC be set explicitly (it ignores CC from env in some configs)
mkdir -p "${BDIR}"
cd "${BDIR}"

echo "libc_cv_slibdir=/usr/lib" > config.cache
echo "libc_cv_ssp_strong=yes" >> config.cache

CC=clang \
"${SDIR}/configure" \
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
    --enable-bind-now \
    --enable-memory-tagging

make -j$(nproc)
make install_root="${LFS}/target" install

echo "=== glibc ${VERSION} complete ==="
