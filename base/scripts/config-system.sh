#!/usr/bin/env bash
# Final system configuration
set -euo pipefail
source toolchain/env.sh

ROOT="${LFS}/target"
CFG="${PROJECT_SOURCE_DIR}/config"

echo "=== Configuring Aether Linux ==="

# ---- Kernel cmdline ----
mkdir -p "${ROOT}/boot/loader/entries"
cat > "${ROOT}/boot/loader/entries/aether.conf" << 'KCMDLINE'
title   Aether Linux
linux   /boot/vmlinuz-6.14-aether
options rw quiet splash transparent_hugepage=madvise split_lock_detect=off iommu=pt intel_iommu=on intel_pstate=active,hwp_only rcutree.enable_rcu_unlazy=1 preempt=voluntary nowatchdog
KCMDLINE

# ---- Fish shell config ----
mkdir -p "${ROOT}/etc/fish"
cat > "${ROOT}/etc/fish/config.fish" << 'FISHCFG'
# Aether Linux default fish config
set -gx CLICOLOR 1
set -gx COLORTERM truecolor
set -gx EDITOR nano
set -gx VISUAL nano

# Amoled Warm Palette
set -g fish_color_command brmagenta
set -g fish_color_keyword brpurple
set -g fish_color_param yellow
set -g fish_color_error red
set -g fish_color_comment brblack

# LLVM toolchain defaults
set -gx CC clang
set -gx CXX clang++
set -gx LD ld.lld
set -gx AS clang
set -gx AR llvm-ar
set -gx NM llvm-nm
set -gx STRIP llvm-strip
set -gx OBJCOPY llvm-objcopy
set -gx RANLIB llvm-ranlib

set -gx CFLAGS "-march=native -O3 -pipe -fno-plt -rtlib=compiler-rt -unwindlib=libunwind"
set -gx CXXFLAGS $CFLAGS
set -gx LDFLAGS "-fuse-ld=lld -Wl,-O1,--as-needed,-z,relro,-z,now -rtlib=compiler-rt -unwindlib=libunwind"
set -gx MAKEFLAGS "-j"(nproc)

# Aliases
alias ls "eza -lh --icons --group-directories-first"
alias ll "eza -lah --icons --group-directories-first --git"
alias grep rg
alias cat bat
alias sudo "doas"
FISHCFG

# Set fish as default shell for root and users
sed -i 's|/bin/bash$|/usr/bin/fish|' "${ROOT}/etc/passwd" 2>/dev/null || true
echo "/usr/bin/fish" >> "${ROOT}/etc/shells"

# ---- /etc/hosts ----
cat > "${ROOT}/etc/hosts" << 'HOSTS'
127.0.0.1  localhost.localdomain localhost
::1        localhost localhost.localdomain
127.0.1.1  aether.localdomain aether
HOSTS
echo "aether" > "${ROOT}/etc/hostname"

# ---- /etc/fstab ----
cat > "${ROOT}/etc/fstab" << 'FSTAB'
# <file>    <mount>     <type>  <options>                       <dump> <pass>
/dev/sda1   /           ext4    defaults,noatime                0      1
/dev/sda2   swap        swap    sw                              0      0
proc        /proc       proc    nosuid,noexec,nodev             0      0
sysfs       /sys        sysfs   nosuid,noexec,nodev             0      0
devpts      /dev/pts    devpts  gid=5,mode=620                  0      0
tmpfs       /run        tmpfs   nosuid,nodev,mode=0755          0      0
tmpfs       /tmp        tmpfs   nosuid,nodev                    0      0
FSTAB

# ---- systemd-networkd ----
mkdir -p "${ROOT}/etc/systemd/network"
cat > "${ROOT}/etc/systemd/network/20-wired.network" << 'NET'
[Match]
Name=enp*

[Network]
DHCP=ipv4
NET

# Enable systemd services
mkdir -p "${ROOT}/etc/systemd/system/multi-user.target.wants"
ln -sfv /usr/lib/systemd/system/systemd-networkd.service \
    "${ROOT}/etc/systemd/system/multi-user.target.wants/"
ln -sfv /usr/lib/systemd/system/systemd-resolved.service \
    "${ROOT}/etc/systemd/system/multi-user.target.wants/"

echo "=== System configuration complete ==="
