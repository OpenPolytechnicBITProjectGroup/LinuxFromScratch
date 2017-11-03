#!/bin/bash
cd $LFS/sources
tar -xf check-0.11.0.tar.gz
cd check-0.11.0
#configure and make
PKG_CONFIG= ./configure --prefix=/tools
make && make install
#clean up and exit
cd $LFS/sources
rm -rf check-0.11.0
