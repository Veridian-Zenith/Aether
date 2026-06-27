#!/usr/bin/env bash
# Fetch CachyOS kernel patches for the current kernel version
set -euo pipefail

VER="6.14"
PATCHDIR="$(dirname "$0")/patches"
CACHYOS_REPO="https://raw.githubusercontent.com/CachyOS/linux-cachyos/master"

mkdir -p "${PATCHDIR}"

echo "=== Fetching CachyOS patches for Linux ${VER} ==="

PATCHES=(
    "misc/0001-bore-sched.patch"
    "misc/0002-pci-Enable-overrides-for-non-standard-USB-controller.patch"
    "misc/0003-multiq-Allow-multiQ-fair-scheduler.patch"
    "misc/0004-cachyos-sched.patch"
    "misc/0005-misc-fixes.patch"
)

for p in "${PATCHES[@]}"; do
    name="$(basename ${p})"
    url="${CACHYOS_REPO}/${p}"
    echo "  Fetching: ${name}"
    curl -sfL "${url}" -o "${PATCHDIR}/${name}" || echo "  Warning: ${name} not found, skipping"
done

echo "=== Patches in ${PATCHDIR}: ==="
ls -la "${PATCHDIR}"
