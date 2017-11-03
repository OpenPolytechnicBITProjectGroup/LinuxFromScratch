#!/bin/bash
# Installing tclcore
cd $LFS/sources
tar -xf tcl-core8.6.7-src.tar.gz
cd tcl8.6.7
cd unix
#configure and make
./configure --prefix=/tools
make && make install
chmod -v u+w /tools/lib/libtcls8.6.so
# install headers for Expect (the next package)
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
#Cean up and exit
cd $LFS/sources
rm -rf tcl8.6.7
