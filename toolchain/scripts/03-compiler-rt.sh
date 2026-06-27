#!/usr/bin/env bash
# LLVM compiler-rt — runtime libraries for the target
# Replaces libgcc
set -euo pipefail
source toolchain/env.sh

PKG="llvm-project"
VERSION="22.1.6"
SDIR="${LFS_SRC}/llvm-project-${VERSION}.src"
BDIR="${SDIR}/build-compiler-rt"

# Use the source already on the system if available
if [[ -d "/usr/lib/llvm-22/runtime/src" ]]; then
    SDIR="/usr/lib/llvm-22/runtime/src"
elif [[ ! -d "${SDIR}" ]]; then
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/llvm-project-${VERSION}.src.tar.xz"
    tar xf "llvm-project-${VERSION}.src.tar.xz"
fi

mkdir -p "${BDIR}"
cd "${BDIR}"

cmake "${SDIR}/runtimes" \
    -G Ninja \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_ASM_COMPILER=clang \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -DCMAKE_INSTALL_PREFIX="${LFS}/target/usr" \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target ${CXXFLAGS}" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=ON \
    -DCOMPILER_RT_INCLUDE_TESTS=OFF

ninja -j$(nproc)
ninja install

echo "=== compiler-rt ${VERSION} complete ==="
