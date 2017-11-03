#!/bin/bash
#installs Texinfo package
cd $LFS/sources
tar -xf texinfo-6.4.tar.xz
cd texinfo-6.4
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf texinfo-6.4
