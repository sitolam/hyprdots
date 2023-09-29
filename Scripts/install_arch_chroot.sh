#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install arch in chroot        |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

bold=$(tput bold)
normal=$(tput sgr0)

clear
echo "${bold}Welcome to the installation part of arch in chroot${normal}"
sleep 1
clear

# Set the time zone
echo "${bold}Setting timezone ........ ${normal}"
while true; do
    read -p "Is this your time and date: $(date)? (y/N) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]|"" ) new_timezone=$(tzselect)
                test -n "$new_timezone" && ln -sf /usr/share/zoneinfo/$new_timezone /etc/localtime
                ;;
        * ) echo "Please answer yes or no."; break;;
    esac
done
hwclock --systohc
sleep 1
clear



# Localization

# Adding the needed locales
echo "${bold}Adding locales ........ ${normal}"
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#en_US ISO-8859-1/en_US ISO-8859-1/g" /etc/locale.gen
sed -i "s/#nl_BE.UTF-8 UTF-8/nl_BE.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#nl_BE ISO-8859-15/nl_BE ISO-8859-15/g" /etc/locale.gen
sed -i "s/#nl_BE@euro ISO-8859-15/nl_BE@euro ISO-8859-15/g" /etc/locale.gen
sleep 1
clear

# Generate locales
echo "${bold}Generating locales ........ ${normal}"
locale-gen
sleep 1
clear

# Set the right locales
echo "${bold}Setting the right locales ........ ${normal}"
cat << EOF >> /etc/profile
#locale settings
export LANG=en_US.UTF-8
#export LANGUAGE="en_US:en"
export LC_MESSAGES="en_US.UTF-8"
export LC_CTYPE="nl_BE@euro"
export LC_COLLATE="nl_BE@euro"
export LC_TIME="nl_BE"
export LC_NUMERIC="nl_BE"
export LC_MONETARY="nl_BE@euro"
export LC_PAPER="nl_BE"
export LC_TELEPHONE="nl_BE"
export LC_ADDRESS="nl_BE"
export LC_MEASUREMENT="nl_BE"
export LC_NAME="nl_BE"
EOF
cat > /etc/locale.conf << EOF
#locale settings
LANG=en_US.UTF-8
#export LANGUAGE="en_US:en"
LC_MESSAGES="en_US.UTF-8"
LC_CTYPE="nl_BE@euro"
LC_COLLATE="nl_BE@euro"
LC_TIME="nl_BE"
LC_NUMERIC="nl_BE"
LC_MONETARY="nl_BE@euro"
LC_PAPER="nl_BE"
LC_TELEPHONE="nl_BE"
LC_ADDRESS="nl_BE"
LC_MEASUREMENT="nl_BE"
LC_NAME="nl_BE"
EOF
sleep 1
clear



# Defining the hostname
echo "${bold}Defining hostname ........${normal}"
read -p "Which hostname do you want?:" hostname
echo $hostname > /etc/hostname
sleep 1
clear



# Root password
echo "${bold}Defining root password ........${normal}"
passwd root
sleep 1
clear



# Configuring the user account
echo "${bold}Configuring the user account ........${normal}"
sleep 0.5

echo "Making the user account"
read -p "Enter your name for the user account: " username
useradd -m -G wheel -s /bin/bash $username

echo "Setting the password for the user account"
passwd $username

echo "Making the user a root user"
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

sleep 1
clear



# Enabling services
echo "${bold}Enabling services ........${normal}"
sleep 0.5

echo "Enabling the NetworkManger service ........"
systemctl enable NetworkManager
#TODO - add the ssh service

sleep 1
clear



# Grub
echo "${bold}Installing grub ........${normal}"
sleep 0.5
grub-install
sleep 1
clear

echo "${bold}Configuring grub ........${normal}"
sleep 0.5
grub-mkconfig -o /boot/grub/grub.cfg #TODO - os-prober
sleep 1
clear



# Virtualbox compatibility
echo "${bold}Configuring virtualbox compatibility ........${normal}"
sleep 0.5

echo "Editing hook (changing autodetect to block)"
sed -i 's/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/HOOKS=(base udev block modconf kms keyboard keymap consolefont autodetect filesystems fsck)/g' /etc/mkinitcpio.conf
sleep 0.5

echo "Regenerating the images ........"
mkinitcpio -p linux-zen

sleep 1
clear



# Install the theme
echo "${bold}Installing the theme ........${normal}"
sleep 0.5

echo "Changing to the user account ........"
su $username
sleep 0.5

echo "Making the directory ........"
mkdir ~/hyprdots
sleep 0.5

echo "Changing the directory ........"
cd ~/hyprdots
sleep 0.5

echo "Cloning the theme ........"
git clone https://github.com/Sitolam/hyprdots
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
./.extra/install_fpk.sh


exit # leave the user account
exit # to leave the chroot