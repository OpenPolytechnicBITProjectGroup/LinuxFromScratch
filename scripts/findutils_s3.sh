#!/bin/bash
#install findutils package
cd $LFS/sources
tar -xf findutils-4.6.0.tar.gz
cd findutils-4.6.0
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf findutils-4.6.0
