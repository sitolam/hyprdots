#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install arch                  |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

bold=$(tput bold)
normal=$(tput sgr0)

clear
echo "${bold}Welcome to the installation part of arch${normal}"
sleep 1
clear


while true; do
    read -p "${bold}Do you want to change your keyboard layout?${normal} (Y/n) " yn
    case $yn in
        [Yy]|"" )
                while true; do
                    read -p "${bold}Do you want to search your keyboard layout by giving your language, country or layout name?${normal} (Y/n) " yn
                    case $yn in
                        [Yy]|"" ) read -p "Search term: " search_term
                                localectl list-keymaps | grep -i $search_term; break;;
                        [Nn]* ) break;;
                        * ) echo "Please answer yes or no."
                            echo ""
                    esac
                done
                read -p "Layout: " key_layout
                loadkeys $key_layout
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no."
            echo ""
    esac
done

sleep 1
clear


echo "${bold}Wifi${normal}"

wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
    echo "${bold}Online${normal}"
else
    echo "${bold}Offline${normal}"
    echo ""
    while [[ $? -eq 0 ]]
    do
        iwctl device list
        echo "What is your network interface?"
        read -p "Interface: " interface
        clear

        iwctl station $interface scan
        iwctl station $interface get-networks
        echo "To which network you want to connect? "
        read -p "Network: " network
        clear

        echo "What is the password for the network? "
        read -p "Password: " password
        clear

        echo "${bold}Connecting ......${normal}"
        iwctl --passphrase=$password station $interface connect $network
        sleep 1
        clear

        echo "${bold}Waiting to connect .....${normal}"
        sleep 10
        clear
    done
fi
clear


echo "${bold}Making some things faster .....${normal}"
reflector --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

sudo nano /etc/pacman.conf
sed -i "s/#ParalellDownloads = 5/ParalellDownloads = 5/g" /etc/pacman.conf

sleep 1
clear


echo "${bold}Partitioning${normal}"
sleep 0.5
clear

echo "${bold}Making the partitions${normal}" 

calc() { awk "BEGIN{print $*}"; }

# Specify the disk device
lsblk
read -p "What disk you want to partition to? (ex./dev/sda) " device
sleep 0.5
clear


# Create the GPT partition table
sudo parted --script "$device" mklabel gpt

# Create the boot partition (512MB, FAT32)
sudo parted --script "$device" mkpart primary fat32 1MiB 513MiB

while true; do
    read -p "Do you want a swap partition? (Y/n) " yn
    case $yn in
        [Yy]|"" ) 
                read -p "How big of a swap do you want? (ex.16 (in GB)) " swapsize

                # Create the swap partition (size from input)
                sudo parted --script "$device" mkpart primary linux-swap 513MiB "$(calc 513+$swapsize*1024)MiB"
        
                # Create the root partition (rest of the disk, ext4)
                sudo parted --script "$device" mkpart primary ext4 "$(calc 513+$swapsize*1024)MiB" 100%

                # Format the partitions
                sudo mkswap -L archswapt "${device}2"        # Swap partition
                sudo mkfs.ext4 -L archroott "${device}3"     # Root partition
                break;;
        [Nn]* ) 
                # Create the root partition (rest of the disk, ext4)
                sudo parted --script "$device" mkpart primary ext4 513MiB 100%

                # Format the partitions
                sudo mkfs.ext4 -L archroott "${device}2"     # Root partition
                break;;
        * ) echo "Please answer yes or no."
            echo ""
    esac
done


# Format the partitions
sudo mkfs.fat -F 32 -n ARCHBOOTT "${device}1"  # Boot partition
