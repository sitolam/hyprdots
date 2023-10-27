#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install arch                  |--/ /-|#
#|-/ /--| Sitolam                                 |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

set -e
bold=$(tput bold)
normal=$(tput sgr0)

clear
echo "${bold}Welcome to the installation part of arch${normal}"
sleep 1
clear

# Keyboard
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

# Wifi
echo "${bold}Wifi${normal}"

if curl --output /dev/null --silent --head --fail "http://google.com"; then
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

# Reflector and pacman optimazition
echo "${bold}Making some things faster .....${normal}"
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 5/g" /etc/pacman.conf
reflector --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

sleep 1
clear


# Partitioning
echo "${bold}Partitioning${normal}"
sleep 0.5
clear

while true; do
    read -p "How do you want to make you partitions? (Guided:G/Automatic:a(The whole disk) " ga
    case $ga in
        [Gg]|"" )  
                echo "${bold}Go to the wiki or with this link:${normal} https://github.com/Sitolam/hyprdots/wiki/Partitioning ${bold}for the guidelines${normal}"
                read -n 1 -s -r -p "Press any key to continue ... "
                echo ""
                bash
                break;;
        [Aa]* ) 
                echo "${bold}Selecting the disk${normal}"
                # Specify the disk device
                lsblk
                read -p "What disk you want to partition to? (ex./dev/sda) " device
                sleep 0.5

                echo "Wiping the disk .......(press ${bold}ctrl+c${normal} to stop)"
                sleep 5
                sgdisk -Z /dev/sda
                sleep 0.5
                clear

                echo "${bold}Naming the partitions${normal}"
                echo ""
                echo "A partition label should only be used once!"
                sleep 1

                echo "These are the existting partition labels:"
                ls -l /dev/disk/by-label
                read -p "How do you want to call your root partition? (default:archroot) " root
                read -p "How do you want to call your swap partition? (default:archswap) " swap
                read -p "How do you want to call your boot partition? (default:ARCHBOOT) " boot
                sleep 0.5
                clear

                echo "${bold}Making the partitions${normal}" 

                calc() { awk "BEGIN{print $*}"; }

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
                                sudo mkswap -L $swap "${device}2"        # Swap partition
                                sudo mkfs.ext4 -L $root "${device}3"     # Root partition
                                break;;
                        [Nn]* ) 
                                # Create the root partition (rest of the disk, ext4)
                                sudo parted --script "$device" mkpart primary ext4 513MiB 100%

                                # Format the partitions
                                sudo mkfs.ext4 -L $root "${device}2"     # Root partition
                                break;;
                        * ) echo "Please answer yes or no."
                            echo ""
                    esac
                done


                # Format the partitions
                sudo mkfs.fat -F 32 -n $boot "${device}1"  # Boot partition


                # Mounting the partitions

                # Mounting the root partition
                mount /dev/disk/by-label/$root /mnt

                # Mounting the boot partition
                mkdir -p /mnt/boot/efi
                mount /dev/disk/by-label/$boot /mnt/boot/efi

                # Turning on the swap partition
                swapon /dev/disk/by-label/$swap
                
                break;;
        * ) echo "Please answer yes or no."; break;;
    esac
done

while true; do
    read -p "Do you want to enable OS-prober (detecting other operating systems in grub)? (Y/n) " yn
    case $yn in
        [Yy]|"" ) os_prober=1
                  export os_prober
                  break;;
        [Nn]* ) os_prober=0
                break;;
        * ) echo "Please answer yes or no."; break;;
    esac
done
sleep 1
clear

# Installing the packages
echo "${bold}Installing the packages ........${normal}"
if [ os_prober -eq 1 ]; then
pacstrap /mnt base linux-zen linux-firmware sof-firmware base-devel grub efibootmgr os-prober micro git networkmanager
else
pacstrap /mnt base linux-zen linux-firmware sof-firmware base-devel grub efibootmgr micro git networkmanager
fi
sleep 1
clear

# Configuring fstab
echo "${bold}Configuring fstab ........${normal}"
genfstab -L /mnt >> /mnt/etc/fstab
sleep 1
clear



# Chroot

# Download the script
curl -O https://raw.githubusercontent.com/Sitolam/hyprdots/master/Scripts/install_arch_chroot.sh
chmod +x install_arch_chroot.sh
cp install_arch_chroot.sh /mnt/root/install_arch_chroot.sh

# Chroot and execute the script
arch-chroot /mnt /root/install_arch_chroot.sh

# Remove the script
echo "${bold}Removing the chroot script ........${normal}"
rm /mnt/root/install_arch_chroot.sh
sleep 1
clear


# Reboot
echo "${bold}Your system is installed${normal}"
while true; do
    read -p "Do you want to reboot? (Y/n) " yn
    case $yn in
        [Yy]|"" ) reboot; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no."; break;;
    esac
done