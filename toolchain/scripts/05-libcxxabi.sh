#!/usr/bin/env bash
# LLVM libc++abi for target
set -euo pipefail
source toolchain/env.sh

PKG="llvm-project"
VERSION="22.1.6"
SDIR="${LFS_SRC}/llvm-project-${VERSION}.src"
[[ -d "/usr/lib/llvm-22/runtime/src" ]] && SDIR="/usr/lib/llvm-22/runtime/src"

BDIR="${SDIR}/build-libcxxabi"

mkdir -p "${BDIR}"
cd "${BDIR}"

cmake "${SDIR}/runtimes" \
    -G Ninja \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -DCMAKE_INSTALL_PREFIX="${LFS}/target/usr" \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CXXFLAGS}" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi" \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_SHARED=ON \
    -DLIBCXXABI_INCLUDE_TESTS=OFF

ninja -j$(nproc)
ninja install

echo "=== libc++abi ${VERSION} complete ==="
