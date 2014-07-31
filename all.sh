#!/usr/bin/bash

# Assuming a 64-bit Linux machine

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
sudo apt-get install curl python-minimal git bison flex bc libcap-dev cmake build-essential

# All source in source, tools in tools
cd ~
mkdir source
mkdir tools

# cryptominisat 4 (first class sat used by stp)
#  could build after: git clone https://github.com/msoos/cryptominisat.git
cd ~/tools
curl -O http://msoos.org/largefiles/cryptominisat_4.2-5_amd64.deb
sudo dpkg -i cryptominisat_4.2-5_amd64.deb

# Klee building

echo 'export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu' >> ~/.bashrc
echo 'export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu' >> ~./bashrc
export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

#  llvm-gcc compiler (prebuilt image)
cd ~/source
curl -O http://llvm.org/releases/2.9/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2
cd ~/tools
tar xvjf ~/source/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2
echo 'PATH=~/llvm-gcc4.2-2.9-x86_64/bin:$PATH' >> ~/.bashrc
echo 'export PATH' >> ~/.bashrc
PATH=~/llvm-gcc4.2-2.9-x86_64/bin:$PATH
export PATH

#  llvm 2.9 release (to be built by llvm-gcc compiler, use to build klee)
cd ~/source
curl -O http://llvm.org/releases/2.9/llvm-2.9.tgz
tar xvzf ../llvm-2.9.tgz

cd llvm-2.9
# cmake? 
./configure --enable-optimized --enable-assertions
make

# STP building
cd ~/tools
git clone https://github.com/stp/stp.git
cd stp
mkdir build
cd build
cmake ..
make
sudo make install

echo 'ulimit -s unlimited' >> ~/.bashrc
ulimit -s unlimited


# klee-uclibc building
cd ~/Tools
git clone --depth 1 --branch klee_0_9_29 https://github.com/ccadar/klee-uclibc.git

