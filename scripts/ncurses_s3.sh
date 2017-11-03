#!/bin/bash
cd $LFS/sources
tar -xf ncurses-6.0.tar.gz
cd ncurses-6.0
#configure and make
sed -i s/mawk// configure
./configure --prefix=/tools	\
	--with-shared		\
	--without-debug		\
	--without-ada		\
	--enable-widec		\
	--enable-overwrite
make && make install
#clean up and exit
cd $LFS/sources
rm -rf ncurses-6.0
