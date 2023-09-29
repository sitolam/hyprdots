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

# Reflector and pacman optimazition
echo "${bold}Making some things faster .....${normal}"
reflector --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

sudo nano /etc/pacman.conf
sed -i "s/#ParalellDownloads = 5/ParalellDownloads = 5/g" /etc/pacman.conf

sleep 1
clear


# Partitioning
echo "${bold}Partitioning${normal}"
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



# Installing the packages
echo "${bold}Installing the packages ......${normal}"
pacstrap /mnt base linux-zen linux-firmware sof-firmware base-devel grub efibootmgr micro git networkmanager
sleep 1
clear

# Configuring fstab
echo "${bold}Configuring fstab ........${normal}"
genfstab -L /mnt >> /mnt/etc/fstab
sleep 1
clear

cat <<EOF > /mnt/root/install_arch_chroot.sh
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
cat << INNER_EOF >> /etc/profile
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
INNER_EOF
cat > /etc/locale.conf << INNER_EOF
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
INNER_EOF



# Root password

exit # to leave the chroot
EOF


arch-chroot /mnt /root/install_arch_chroot.sh

# Remove the script
echo "${bold}Removing the chroot script ........${normal}"
rm /mnt/root/install_arch_chroot.sh
sleep 1
clear

# Unmount the drives
echo "${bold}Unmounting the drives ........${normal}"
umount -a
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