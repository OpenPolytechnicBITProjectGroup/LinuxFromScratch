#!/bin/bash
#Install the coreutils package
cd $LFS/sources
tar -xf coreutils-8.27.tar.xz
cd coreutils-8.27
# congiure and install
./configure --prefix=/tools --enable-install-program=hostname
make && make install
#clean up and exit
cd $LFS/sources
rm -rf coreutils-8.27

