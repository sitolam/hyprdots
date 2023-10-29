#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to setup applications            |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)\

# Virt-manager
echo "Virt-manager"
sleep 0.5
sudo systemctl enable libvirtd.service
sleep 1
clear

exit