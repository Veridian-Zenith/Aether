#!/usr/bin/env bash
# LLVM libc++ for target (replaces libstdc++)
set -euo pipefail
source toolchain/env.sh

PKG="llvm-project"
VERSION="22.1.6"
SDIR="${LFS_SRC}/llvm-project-${VERSION}.src"
[[ -d "/usr/lib/llvm-22/runtime/src" ]] && SDIR="/usr/lib/llvm-22/runtime/src"

BDIR="${SDIR}/build-libcxx"

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
    -DLLVM_ENABLE_RUNTIMES="libcxx" \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_CXX_ABI_INCLUDE_PATHS="${SDIR}/libcxxabi/include" \
    -DLIBCXX_HAS_MUSL_LIBC=OFF \
    -DLIBCXX_INCLUDE_TESTS=OFF

ninja -j$(nproc)
ninja install

echo "=== libc++ ${VERSION} complete ==="
