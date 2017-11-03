#!/bin/bash
#install gawk package
cd $LFS/sources
tar -xf gawk-4.1.4.tar.xz
cd gawk-4.1.4
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf gawk-4.1.4
