#!/usr/bin/env bash
# Create the LFS directory tree
source "$(dirname "$0")/env.sh"

mkdir -pv "${LFS}/cross-tools"
mkdir -pv "${LFS}/target"

# Target filesystem skeleton
mkdir -pv "${LFS}/target"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
mkdir -pv "${LFS}/target/etc"/{opt,sysconfig}
mkdir -pv "${LFS}/target/lib/firmware"
mkdir -pv "${LFS}/target/media"/{cdrom,floppy,usb}
mkdir -pv "${LFS}/target/usr"/{bin,include,lib,libexec,local,sbin,share,src}
mkdir -pv "${LFS}/target/var"/{cache,lib,local,lock,log,mail,opt,run,spool,tmp}
install -dv -m 0750 "${LFS}/target/root"
install -dv -m 1777 "${LFS}/target/tmp" "${LFS}/target/var/tmp"

echo "Created LFS directory tree at ${LFS}"
