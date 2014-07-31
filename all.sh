#!/bin/bash

# Assuming a new 64-bit Linux machine (image)

# sudo apt-get install -y git
# cd
# git clone https://github.com/Butterwell/a.git
# a/all.sh # this file
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

~/a/klee.sh
~/a/klee-coreutil.sh

