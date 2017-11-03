#!/bin/bash
#installs patch package
cd $LFS/sources
tar -xf patch-2.7.5.tar.xz
cd patch-2.7.5
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf patch-2.7.5
