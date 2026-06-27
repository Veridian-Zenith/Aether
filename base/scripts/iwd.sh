#!/usr/bin/env bash
# iwd — WiFi daemon with built-in DHCP
set -euo pipefail
source toolchain/env.sh

PKG="iwd"
VERSION="3.0"
SDIR="${LFS_SRC}/iwd-${VERSION}"

[[ -d "${SDIR}" ]] || {
    mkdir -p "${LFS_SRC}"
    cd "${LFS_SRC}"
    wget "https://www.kernel.org/pub/linux/network/wireless/iwd-${VERSION}.tar.xz"
    tar xf "iwd-${VERSION}.tar.xz"
}

BDIR="${SDIR}/build"
mkdir -p "${BDIR}"
cd "${BDIR}"

CC=clang \
CFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -O2 -pipe" \
LDFLAGS="--target=${LFS_TGT} --sysroot=${LFS}/target -fuse-ld=lld" \
"${SDIR}/configure" \
    --prefix=/usr \
    --host="${LFS_TGT}" \
    --build="$(uname -m)-linux-gnu" \
    --enable-client \
    --enable-monitor \
    --enable-builtin-dhcp-client \
    --enable-systemd-service \
    --disable-dbus-policy

make -j$(nproc)
make DESTDIR="${LFS}/target" install

# Enable IWD's built-in DHCP
mkdir -p "${LFS}/target/etc/iwd"
cat > "${LFS}/target/etc/iwd/main.conf" << 'EOF'
[General]
EnableNetworkConfiguration=true
EOF

echo "=== iwd ${VERSION} complete ==="
