#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install arch in chroot (user) |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)

echo "Making the directory ........"
mkdir ~/hyprdots
sleep 0.5

echo "Changing the directory ........"
cd ~/hyprdots
sleep 0.5

echo "Cloning the theme ........"
git clone --depth 1 https://github.com/Sitolam/hyprdots
cd hyprdots/Scripts
sleep 1

clear

echo "${bold}Are you ready?!${normal}"
sleep 1
clear

echo "${bold}Installing the theme ........ ${normal}"
sleep 0.5
./install.sh -drs custom_apps.lst
sleep 1
clear

echo "Installing the flatpaks ........"
sudo ./.extra/install_fpk.sh


exit # leave the user account
