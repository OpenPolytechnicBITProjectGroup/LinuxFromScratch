#!/bin/bash
#Exposes the kernel's API for use by glibc
cd $LFS/sources
tar -xf linux-4.12.7.tar.xz
cd linux-4.12.7
## make sure there are no stale files in the package
make mrproper
# extract the user-visible kernel
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
# exit and remove package
cd $LFS/sources
rm -rf linux-4.12.7

