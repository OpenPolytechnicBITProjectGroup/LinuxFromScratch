#!/bin/bash
cd $LFS/sources
tar -xf bash-4.4.tar.gz
cd bash-4.4
#configure and make
./configure --prefix=/tools --without-bash-malloc
make && make install
ln -sv bash /tools/bin/sh
#clean and exit
cd $LFS/sources
rm -rf bash-4.4
