#!bin/bash
#Auto install script for first stages of Chapter 5 LFS
# Assumes you have downloaded sources files and have $LFS/sources set up
cd $LFS/sources
## Add binutil_s1 & gcc_s1 scripts here
bash binutils_s1.sh
bash gcc_pass1.sh
## api header
bash linux_api_s1.sh
## instal glibc
bash glibc_s1.sh
##endo fo Stage1
echo 'You have finished Chapter 5 - stage 1: bash test_dummy.sh to test the toolchain before commencing stage 2'
