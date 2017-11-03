#!/bin/bash
#installs Tar package
cd $LFS/sources
tar -xf tar-1.29.tar.xz
cd tar-1.29
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf tar-1.29
