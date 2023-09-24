#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install arch                  |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

bold=$(tput bold)
normal=$(tput sgr0)

clear
echo "${bold}Welcome to the installation part of arch${normal}"


wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
    echo "Online"
else
    echo "Offline"
fi
