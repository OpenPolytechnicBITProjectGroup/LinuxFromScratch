#!/bin/bash
#Install Util-linux package
cd $LFS/sources
tar -xf util-linux-2.30.1.tar.xz
cd util-linux-2.30.1
#configure and install
./configure				\
	--prefix=/tools			\
	--without-python		\
	--disable-makeinstall-chown	\
	--without-systemdsystemunitdir	\
	--without-ncurses		\
	PKG_CONFIG=""
make && make install
#clean and exit
cd $LFS/sources
rm -rf util-linux-2.30.1
