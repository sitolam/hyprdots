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


# Root password

exit # to leave the chroot