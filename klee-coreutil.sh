#!/bin/bash

# Coreutils run with Klee

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu

sudo apt-get install python-pip
sudo pip install tabulate

cd ~/source
curl -O http://ftp.gnu.org/gnu/coreutils/coreutils-6.11.tar.gz
tar xvzf coreutils-6.11.tar.gz

# gcov
cd ~/source/coreutils-6.11
mkdir obj-gcov
cd obj-gcov
../configure --disable-nls CFLAGS="-g -fprofile-arcs -ftest-coverage"
make
make -C src arch hostname

# llvm
cd ~/source/coreutils-6.11
mkdir obj-llvm
cd obj-llvm
../configure --disable-nls CFLAGS="-g"
export cc=~/source/klee/scripts/klee-gcc
make CC=$cc
make -C src arch hostname CC=$cc

# visual tests
cd ~/source/coreutils-6.11/obj-gcov/src
ls -l ls echo cat
./cat --version
rm -f *.gcda
./echo "Yes"
ls -l echo.gcda
gcov echo

cd ~/source/coreutils-6.11/obj-llvm/src
ls -l ls echo cat
klee --libc=uclibc --posix-runtime ./cat.bc --version
klee --libc=uclibc --posix-runtime ./echo.bc --help
klee --libc=uclibc --posix-runtime ./echo.bc --sym-arg 3
klee-stats klee-last
klee --optimize --libc=uclibc --posix-runtime ./echo.bc --sym-arg 3
klee-stats klee-last

