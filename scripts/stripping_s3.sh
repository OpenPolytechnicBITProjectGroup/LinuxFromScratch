#!/bin/bash
#Strips the partition of unnecessary debugging symbols -- OPTIONAL
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
