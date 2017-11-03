#!/bin/bash
cd $LFS/sources
tar -xf gcc-7.2.0.tar.xz
cd gcc-7.2.0
mkdir -v build
cd build
#prepare libstdc for compiltation
../libstdc++-v3/configure		\
	--host=$LFS_TGT			\
	--prefix=/tools			\
	--disable-multilib		\
	--disable-nls			\
	--disable-libstdcxx-threads	\
	--disable-libstdcxx-pch		\
	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.2.0
make && make install
#clean upp and exit
cd $LFS/sources
rm -rf gcc-7.2.0
