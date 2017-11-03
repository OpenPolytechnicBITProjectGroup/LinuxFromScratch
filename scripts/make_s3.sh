#!/bin/bash
#installs make package
cd $LFS/sources
tar -xjf make-4.2.1.tar.bz2
cd make-4.2.1
#configure and install
./configure --prefix=/tools --without-guile
make && make install
#clean and exit
cd $LFS/sources
rm -rf make-4.2.1
