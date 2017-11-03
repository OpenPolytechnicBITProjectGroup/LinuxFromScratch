#!/bin/bash
#DejaGNU package
cd $LFS/sources
tar -xf dejagnu-1.6.tar.gz
cd dejagnu-1.6
#configure and install
./configure --prefix=/tools
make install
#clean and exit
cd $LFS/sources
rm -rf dejagnu-1.6
