#!/usr/bin/env bash
source toolchain/env.sh

mkdir -pv "${LFS}/cross-tools"
mkdir -pv "${LFS}/target"/{boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
mkdir -pv "${LFS}/target/etc"/{opt,sysconfig,fish}
mkdir -pv "${LFS}/target/usr"/{bin,include,lib,libexec,local,sbin,share,src}
mkdir -pv "${LFS}/target/var"/{cache,lib,local,lock,log,mail,opt,run,spool,tmp}
install -dv -m 0750 "${LFS}/target/root"
install -dv -m 1777 "${LFS}/target/tmp" "${LFS}/target/var/tmp"

echo "Created LFS directory tree at ${LFS}"
