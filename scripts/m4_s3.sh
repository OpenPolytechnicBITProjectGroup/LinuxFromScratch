#!/bin/bash
#installs the M4 package
cd $LFS/sources
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf m4-1.4.18
