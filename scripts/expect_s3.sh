#!/bin/basj
#expect package for scripted dialogues
cd $LFS/sources
tar -xf expect5.45.tar.gz
cd expect5.45
#configure the package
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools 		\
	--with-tcl=/tools/lib		\
	--with-tclinclude=/tools/include
make
make SCRIPTS="" install
#clean up and exit
cd $LFS/sources
rm -rf expect5.45
