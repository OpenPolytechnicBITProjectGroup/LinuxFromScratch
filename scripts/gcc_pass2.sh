#!/bin/bash
# Compiling the c & c++ collection
cd $LFS/sources
tar -xf gcc-7.2.0.tar.xz
cd gcc-7.2.0
# Sewtup the install
#create full internal header
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
	`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
#change default dynamic linker
for file in gcc/config/{linux,i386/linux{,64}}.h
do
	cp -uv $file{,.orig}
	sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
		-e 's@/usr@/tools@g' $file.orig > $file
	echo '
	#undef STANDDARD_STARTFILE_PREFIX_1
	#undef STANDARD_STARTFILE_PREFIX_2
	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
	touch $file.orig
done
# Building on x86_64
case $(uname -m) in
	x86_64)
		sed -e '/m64=/s/lib64/lib/' \
			-i.orig gcc/config/i386/t-linux64
		;;
esac
# Get required packages
tar -xf ../mpfr-3.1.5.tar.xz
mv -v mpfr-3.1.5 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc
# create build directory
mkdir -v build
cd build
#prepare gcc for compilation
CC=$LFS_TGT-gcc					\
	CXX=$LFS_TGT-g++			\
	AR=$LFS_TGT-ar				\
	RANLIB=$LFS_TGT-ranlib			\
	../configure				\
	--prefix=/tools				\
	--with-local-prefix=/tools		\
	--with-native-system-header-dir=/tools/include	\
	--enable-languages=c,c++		\
	--disable-libstdcxx-pch			\
	--disable-multilib			\
	--disable-bootstrap			\
	--disable-libgomp
#make, install & symlink
make && make install
ln -sv gcc /tools/bin/cc
#clean up and exit
cd $LFS/sources
rm -rf gcc-7.2.0
