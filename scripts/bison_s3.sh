#!/bin/bash
cd $LFS/sources
tar -xf bison-3.0.4.tar.xz
cd bison-3.0.4
##configure and make
./configure --prefix=/tools
make & make install
#clean up and exit
cd $LFS/sources
rm -rf bison-3.0.4
