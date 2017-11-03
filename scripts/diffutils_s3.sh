#!/bin/bash
#install diffutils package
cd $LFS/sources
tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6
# configure and install
./configure --prefix=/tools
make && make install
# clean and exit
cd $LFS/sources
rm -rf diffutils-3.6
