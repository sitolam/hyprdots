#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to setup applications            |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)\


# Wayvnc
mkdir -p ~/Downloads/github/wayvnc/
cd ~/Downloads/github/wayvnc/
sudo pacman -S base-devel libglvnd libxkbcommon pixman gnutls jansson

git clone https://github.com/any1/wayvnc.git
git clone https://github.com/any1/neatvnc.git
git clone https://github.com/any1/aml.git

mkdir wayvnc/subprojects
cd wayvnc/subprojects
ln -s ../../neatvnc .
ln -s ../../aml .
cd -

mkdir neatvnc/subprojects
cd neatvnc/subprojects
ln -s ../../aml .
cd -
#TODO: automate patch https://github.com/any1/wayvnc/issues/248


cd wayvnc

meson build
ninja -C build

exit