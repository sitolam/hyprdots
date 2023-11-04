#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to setup applications            |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)\


# Wayvnc 
echo "${bold}Installing wayvnc${normal}"
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

sleep 1
clear


# Autologin
echo "${bold}Configuring autologin${normal}"
sudo sed -i '/#%PAM-1.0/a \auth      sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
sudo sed -i "s/Session=/Session=hyprland/s" /etc/sddm.conf.d/kde_settings.conf
sudo sed -i "s/User=/User=$USER/s" /etc/sddm.conf.d/kde_settings.conf

mkdir -p ~/.config/autostart
cat <<EOF > ~/.config/autostart/swaylock.desktop
[Desktop Entry]
Name=Swaylock
Comment=Starting swaylock at login
Exec=swaylock --gracer 0
Type=Application
Terminal=i
Hidden=false
EOF

sleep 1
clear

# Anki
echo "${bold}Adding Anki plugins${normal}"
while true; do
    read -p "Do you want to copy the Anki plugins? (you need the password) (Y/n) " yn
    case $yn in
        [Yy]|"" ) 
                wget https://github.com/Sitolam/hyprdots/releases/download/v1.0.0/anki_plugins.7z
                7z x anki_plugins.7z
                cp -r addons21 ~/.local/share/Anki2
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no."; break;;
    esac
done
sleep 1
clear



exit