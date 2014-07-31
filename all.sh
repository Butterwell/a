#!/bin/bash

# Assuming a new 64-bit Linux machine (image)

# sudo apt-get install -y git
# git clone https://github.com/Butterwell/a.git
# ./a/all.sh # This file
#
# If running on VirtualBox, start with this and enable bi-directional cut-and-paste
# sudo apt-get install build-essential
# "Insert Guest Additions" from the Device tab
# df to find the newly mounted media
# cd to the directory and
# sudo ./VBoxLin*
# reboot the virtual machine
# A warning message about a lack of system headers can be removed with:
# sudo apt-get linux-headers-$(uname -r)

# All package installs up front

sudo apt-get update
sudo apt-get install -y curl python-minimal git bison flex bc libcap-dev cmake build-essential libboost-all-dev libncurses5-dev libncursesw5-dev

# All source in source, tools in tools
cd ~
[ ! -e source ] && mkdir source
[ ! -e tools ] && mkdir tools

echo 'export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu' >> ~/.bashrc
echo 'export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu' >> ~/.bashrc
export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

# Klee prelimiaries

# cryptominisat 4 (first class sat used by stp)
#  could build after: git clone https://github.com/msoos/cryptominisat.git
cd ~/tools
[ ! -e cryptominisat_4.2-5_amd64.deb ] && curl -O http://msoos.org/largefiles/cryptominisat_4.2-5_amd64.deb
sudo dpkg -i cryptominisat_4.2-5_amd64.deb

#  llvm-gcc compiler (prebuilt image)
cd ~/source
[ ! -e llvm-gcc4.2-2.9-x86_64-linux.tar.bz2 ] && curl -O http://llvm.org/releases/2.9/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2
cd ~/tools
[ ! -e llvm-gcc4.2-2.9-x86_64-linux ] && tar xvjf ~/source/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2
echo 'PATH=~/tools/llvm-gcc4.2-2.9-x86_64-linux/bin:$PATH' >> ~/.bashrc
echo 'export PATH' >> ~/.bashrc
export PATH=~/tools/llvm-gcc4.2-2.9-x86_64-linux/bin:$PATH

#  llvm 2.9 release (build in source)
cd ~/source
[ ! -e llvm-2.9.tgz ] && curl -O http://llvm.org/releases/2.9/llvm-2.9.tgz
[ ! -e llvm-2.9 ] && tar xvzf llvm-2.9.tgz

# Fix lseek64 not found, from: http://www.mail-archive.com/klee-dev@imperial.ac.uk/msg01302.html
patch -N llvm-2.9/lib/ExecutionEngine/JIT/Intercept.cpp << EOF
diff -u -r llvm-2.9/lib/ExecutionEngine/JIT/Intercept.cpp src/lib/ExecutionEngine/JIT/Intercept.cpp
--- llvm-2.9/lib/ExecutionEngine/JIT/Intercept.cpp	2010-11-29 18:16:10.000000000 +0000
+++ src/lib/ExecutionEngine/JIT/Intercept.cpp	2013-09-27 12:11:02.464085889 +0100
@@ -50,6 +50,7 @@
 #if defined(__linux__)
 #if defined(HAVE_SYS_STAT_H)
 #include <sys/stat.h>
+#include <unistd.h>
 #endif
 #include <fcntl.h>
 /* stat functions are redirecting to __xstat with a version number.  On x86-64 
EOF

cd llvm-2.9
[ ! -e Release+Asserts ] && ./configure --enable-optimized --enable-assertions
make
export PATH=~/source/llvm-2.9/Release+Asserts/bin:$PATH

# There is cmake materials in llvm-2.9. If they work, this is what you'd do:
#mkdir build
#cd build
#cmake ..
#make

# STP building (build in tools)
cd ~/source
[ ! -e stp ] && git clone https://github.com/stp/stp.git
cd ~/tools
[ ! -e stp ] && mkdir stp
cd stp
cmake ~/source/stp
make
sudo make install

echo 'ulimit -s unlimited' >> ~/.bashrc
ulimit -s unlimited

# klee-uclibc building (build in source)
cd ~/source
[ ! -e klee-uclibc ] && git clone --depth 1 --branch klee_0_9_29 https://github.com/ccadar/klee-uclibc.git
cd klee-uclibc
[ ! -e libm/k_cos.os ] && ./configure --make-llvm-lib
make

# KLEE
cd ~/source
[ ! -e klee ] && git clone https://github.com/klee/klee.git
cd klee
[ ! -e Release+Asserts ] && ./configure --with-llvm=../llvm-2.9 --with-stp=../../tools/stp --with-uclibc=../klee-uclibc --enable-posix-runtime
make ENABLE_OPTIMIZED=1
make check
make unittests
sudo make install

#echo "Restart terminal for new PATH (new tools)"
