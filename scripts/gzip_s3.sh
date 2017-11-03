#!/bin/bash
#installs gzip package
cd $LFS/sources
tar -xf gzip-1.8.tar.xz
cd gzip-1.8
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf gzip-1.8
