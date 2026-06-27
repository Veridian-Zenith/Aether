#!/usr/bin/env bash
# Enter the LFS chroot environment
# Requires: root
set -euo pipefail

source scripts/env.sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: chroot requires root. Run with: sudo $0"
    exit 1
fi

# Mount virtual kernel filesystems
mount -v --bind /dev "${LFS}/target/dev"
mount -v --bind /dev/pts "${LFS}/target/dev/pts"
mount -vt proc proc "${LFS}/target/proc"
mount -vt sysfs sysfs "${LFS}/target/sys"
mount -vt tmpfs tmpfs "${LFS}/target/run"

# Prepare chroot environment
chroot "${LFS}/target" /usr/bin/env \
    HOME=/root \
    TERM="${TERM}" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH="/usr/bin:/usr/sbin" \
    MAKEFLAGS="-j$(nproc)" \
    /bin/bash --login
