#!/usr/bin/env bash
# Base system: GRUB bootloader
set -euo pipefail

source scripts/env.sh

PKG="grub"
VERSION="2.12"
SOURCE_DIR="${LFS}/sources/${PKG}-${VERSION}"

echo "=== Building ${PKG}-${VERSION} ==="

mkdir -p "${LFS}/sources"
if [ ! -d "${SOURCE_DIR}" ]; then
    cd "${LFS}/sources"
    if [ ! -f "grub-${VERSION}.tar.xz" ]; then
        wget "https://ftp.gnu.org/gnu/grub/grub-${VERSION}.tar.xz"
    fi
    tar xf "grub-${VERSION}.tar.xz"
fi

cd "${SOURCE_DIR}"

./configure \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --sysconfdir=/etc \
    --disable-efiemu \
    --enable-grub-mount \
    --enable-grub-mkfont \
    --with-platform=efi \
    --disable-werror

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Generate GRUB config
mkdir -p "${LFS}/target/boot/grub"
cat > "${LFS}/target/boot/grub/grub.cfg" << 'EOF'
set default=0
set timeout=5

menuentry "Aether Linux" {
    linux   /boot/vmlinuz-6.14-aether root=/dev/sda1 ro quiet
}
EOF

echo "=== ${PKG}-${VERSION} complete ==="
