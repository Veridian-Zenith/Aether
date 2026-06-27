#!/usr/bin/env bash
# LLVM lld — linker for the target (replaces GNU ld.bfd)
set -euo pipefail
source toolchain/env.sh

PKG="llvm-project"
VERSION="22.1.6"
SDIR="${LFS_SRC}/llvm-project-${VERSION}.src"
[[ -d "/usr/lib/llvm-22/runtime/src" ]] && SDIR="/usr/lib/llvm-22/runtime/src"

BDIR="${SDIR}/build-lld"

mkdir -p "${BDIR}"
cd "${BDIR}"

cmake "${SDIR}/lld" \
    -G Ninja \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -DCMAKE_INSTALL_PREFIX="${LFS}/cross-tools" \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CXXFLAGS}" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_LLD=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LIBCXXABI=ON \
    -DLLVM_ENABLE_UNWINDER=ON \
    -DLLVM_ENABLE_PROJECTS="lld"

ninja -j$(nproc)
ninja install

# Create symlinks for ld
ln -sfv lld "${LFS}/cross-tools/bin/ld"
ln -sfv ld.lld "${LFS}/cross-tools/bin/ld.lld"

echo "=== lld ${VERSION} complete ==="
