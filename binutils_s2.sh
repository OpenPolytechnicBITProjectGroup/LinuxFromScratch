#!/bin/bash
# Pass 2 of binutils
cd $LFS/sources
tar -xjf binutils-2.29.tar.bz2
cd binutils-2.29
mkdir -v build
cd build
#prepare for compiltation
CC=$LFS_TGT-gcc			\
	AR=$LFS_TGT-ar		\
	RANLIB=$LFS_TGT-ranlib	\
	../configure		\
	--prefix=/tools		\
	--disable-nls		\
	--disable-werror	\
	--with-lib-path=/tools/lib	\
	--with-sysroot
make && make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
#clean up and exit
cd $LFS/sources
rm -rf binutils-2.29
