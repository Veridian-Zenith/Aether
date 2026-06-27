#!/usr/bin/env bash
# llvm-libc — the Aether system C library
# Built with host clang, no glibc dependency.
# Depends on: linux-headers, compiler-rt builtins
set -euo pipefail
source toolchain/env.sh

PKG="llvm-project"
VERSION="22.1.6"
SDIR="${LFS_SRC}/llvm-project-${VERSION}.src"
[[ -d "/usr/lib/llvm-22/runtime/src" ]] && SDIR="/usr/lib/llvm-22/runtime/src"

BDIR="${SDIR}/build-llvm-libc"

echo "=== Building llvm-libc (libllvmlibc) ==="

mkdir -p "${BDIR}"
cd "${BDIR}"

cmake "${SDIR}/libc" \
    -G Ninja \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_ASM_COMPILER=clang \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -DCMAKE_INSTALL_PREFIX="${LFS}/target/usr" \
    -DCMAKE_C_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe -fno-plt -fstack-protector-strong -D_FORTIFY_SOURCE=3" \
    -DCMAKE_CXX_FLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe -fno-plt -fstack-protector-strong -D_FORTIFY_SOURCE=3" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld -rtlib=compiler-rt" \
    -DCMAKE_SYSROOT="${LFS}/target" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_LIBC_FULL_BUILD=ON \
    -DLIBC_TARGET_MACHINE="x86_64" \
    -DLIBC_TARGET_OS="linux" \
    -DLIBC_INCLUDE_TESTS=OFF \
    -DLIBC_INCLUDE_BENCHMARKS=OFF \
    -DLIBC_ENABLE_LINTING=OFF \
    -DLIBC_NAMESPACE="__llvm_libc"

ninja -j$(nproc)
ninja install

# Create standard symlinks: libc.so → libllvmlibc.so
ln -sfv libllvmlibc.so "${LFS}/target/usr/lib/libc.so"
ln -sfv libllvmlibc.so "${LFS}/target/usr/lib/libm.so"
ln -sfv libllvmlibc.so "${LFS}/target/usr/lib/libpthread.so"
ln -sfv libllvmlibc.so "${LFS}/target/usr/lib/librt.so"
ln -sfv libllvmlibc.so "${LFS}/target/usr/lib/libdl.so"

# Install config
mkdir -p "${LFS}/target/etc"
cp -v "${PROJECT_SOURCE_DIR}/config/llvm-libc.conf" "${LFS}/target/etc/"

echo "=== llvm-libc ${VERSION} complete ==="
