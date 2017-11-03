#!/bin/bash
#installs the Xz package
cd $LFS/sources
tar -xf xz-5.2.3.tar.xz
cd xz-5.2.3
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf xz-5.2.3
