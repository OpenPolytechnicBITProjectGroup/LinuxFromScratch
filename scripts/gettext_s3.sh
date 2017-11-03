#!/bin/bash
#install gettext package with NLS support
cd $LFS/sources
tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1
#configure and install
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
#clean and exit
cd $LFS/sources
rm -rf gettext-0.19.8.1
