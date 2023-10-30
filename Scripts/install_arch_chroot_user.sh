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

echo "Cloning the repository ........"
git clone --depth 1 https://github.com/Sitolam/hyprdots
cd hyprdots/Scripts
sleep 1

clear

echo "${bold}Configuring custom services ........${normal}"
sleep 0.5
find .services -maxdepth 1 -type f | sudo xargs cp -t /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable easy-novnc.service
sudo systemctl enable wayvnc.service

echo "${bold}Are you ready?!${normal}"
sleep 1
clear

echo "${bold}Installing the theme ........ ${normal}"
sleep 0.5
./install.sh -drs custom_apps.lst
sleep 1
clear

# echo "Installing the flatpaks ........"
# ./.extra/install_fpk.sh

echo "${bold}Setting up applications ........${normal}"
sleep 0.5
./setup_applications.sh
sleep 1
clear



exit # leave the user account
