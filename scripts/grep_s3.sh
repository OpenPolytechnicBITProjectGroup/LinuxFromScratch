#!/bin/bash
cd $LFS/sources
tar -xf grep-3.1.tar.xz
cd grep-3.1
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf grep-3.1
