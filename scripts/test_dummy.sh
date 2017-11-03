#!/bin/bash
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
echo 'OK : clean up test files with "rm -v dummy.c a.out"'
