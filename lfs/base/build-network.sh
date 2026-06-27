#!/usr/bin/env bash
# Base system: Network configuration
set -euo pipefail

source scripts/env.sh

echo "=== Configuring network ==="

# Hostname
echo "aether" > "${LFS}/target/etc/hostname"

# Static hosts
cat > "${LFS}/target/etc/hosts" << 'EOF'
127.0.0.1  localhost.localdomain localhost
::1        localhost localhost.localdomain
127.0.1.1  aether.localdomain aether
EOF

# Network interfaces (systemd-networkd style)
mkdir -p "${LFS}/target/etc/systemd/network"
cat > "${LFS}/target/etc/systemd/network/20-wired.network" << 'EOF'
[Match]
Name=enp*

[Network]
DHCP=ipv4
EOF

# /etc/fstab
mkdir -p "${LFS}/target/etc"
cat > "${LFS}/target/etc/fstab" << 'EOF'
# <file>    <mount>    <type>    <options>              <dump> <pass>
/dev/sda1   /          ext4      defaults,noatime        0      1
/dev/sda2   swap       swap      sw                      0      0
proc        /proc      proc      nosuid,noexec,nodev     0      0
sysfs       /sys       sysfs     nosuid,noexec,nodev     0      0
devpts      /dev/pts   devpts    gid=5,mode=620          0      0
tmpfs       /run       tmpfs     nosuid,nodev,mode=0755  0      0
tmpfs       /tmp       tmpfs     nosuid,nodev            0      0
EOF

echo "=== Network configuration complete ==="
