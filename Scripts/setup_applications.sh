#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to setup applications            |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)\


# Wayvnc #TODO: add password protection
mkdir -p /root/wayvnc
cd /root/wayvnc
sudo pacman -S --no-confirm base-devel libglvnd libxkbcommon pixman gnutls jansson

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

cd neatvnc/src
sed -i '/assert(server);/a \    pixman_region_intersect_rect(damage, damage, 0, 0, fb->width,fb->height);' display.c 
#TODO: automate patch https://github.com/any1/wayvnc/issues/248

cd -
cd wayvnc

meson build
ninja -C build

# Autologin
sudo sed -i '/#%PAM-1.0/a \auth      sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
sudo sed -i "s/Session=/Session=hyprland/s" /etc/sddm.conf.d/kde_settings.conf
sudo sed -i "s/User=/User=$USER/s" /etc/sddm.conf.d/kde_settings.conf



exit