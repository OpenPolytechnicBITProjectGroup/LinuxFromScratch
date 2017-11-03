#!/bin/bash
# compile the binutils package
cd $LFS/sources
tar -xjf binutils-2.29.tar.bz2
cd binutils-2.29
mkdir -v build
cd build
# prepare and make
../configure --prefix=/tools		\
	--with-sysroot=$LFS		\
	--with-lib-path=/tools/lib	\
	--target=$LFS_TGT		\
	--disable-nls			\
	--disable-werror
make
#building on x86_64 so create symlink
case $(uname -m) in
	x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac
# install package
make install
# clean up and exit
cd $LFS/sources
rm -rf binutils-2.29
