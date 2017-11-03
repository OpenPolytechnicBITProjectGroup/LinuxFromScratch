#!/bin/bash
#installs sed package
cd $LFS/sources
tar -xf sed-4.4.tar.xz
cd sed-4.4
#configure and install
./configure --prefix=/tools
make && make install
#clean and exit
cd $LFS/sources
rm -rf sed-4.4
