#!/bin/bash

## @knitr MacBLAS

R_VERSION=3.1

cd /Library/Frameworks/R.framework/Versions/${R_VERSION}/Resources/lib
sudo cp libRblas.dylib libRblas.dylib.backup
sudo ln -s /System/Library/Frameworks/Accelerate.framework/Versions/\
Current/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib \
libRblas.dylib

## @knitr etc-alternatives

# to install openBLAS in Ubuntu
sudo apt-get install -y libopenblas-base

ls -l /usr/lib/libblas.so
## lrwxrwxrwx 1 root root 28 Jan  8 19:11 /usr/lib/libblas.so -> 
##     /etc/alternatives/libblas.so
ls -l /etc/alternatives/libblas.so
## lrwxrwxrwx 1 root root 33 Jan 13 16:01 /etc/alternatives/libblas.so -> 
##     /usr/lib/openblas-base/libblas.so

