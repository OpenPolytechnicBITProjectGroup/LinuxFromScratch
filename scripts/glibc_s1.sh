#!/bin/bash
# Install the main C library
cd $LFS/sources
tar -xf glibc-2.26.tar.xz
cd glibc-2.26
mkdir -v build
cd build
# configure and make
../configure			\
	--prefix=/tools		\
	--host=$LFS_TGT		\
	--build=$(../scripts/config.guess)	\
	--enable-kernel=3.2	\
	--with-headers=/tools/include	\
	libc_cv_forced_unwind=yes	\
	libc_cv_c_cleanup=yes
make && make install
# clean up and exit
cd $LFS/sources
rm -rf glibc-2.26
