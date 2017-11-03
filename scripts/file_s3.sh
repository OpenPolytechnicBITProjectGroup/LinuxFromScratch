#!/bin/bash
#install file package
cd $LFS/sources
tar -xf file-5.31.tar.gz
cd file-5.31
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf file-5.31
