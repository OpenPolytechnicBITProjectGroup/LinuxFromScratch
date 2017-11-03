#!/bin/bash
# installs bzip2 package
cd $LFS/sources
tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
#install
make
make PREFIX=/tools install
#clean up and exit
cd $LFS/sources
rm -rf bzip2-1.0.6
