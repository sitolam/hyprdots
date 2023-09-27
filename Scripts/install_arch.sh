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
        [Yy]|"" ) echo "${bold}Do you want to change your keyboard layout?${normal}"
                while true; do
                    read -p "${bold}Do you want to change your keyboard layout?${normal} (Y/n) " yn
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

echo "Making the partitions" 

while true; do
    read -p "How do you want to do the partitioning?  (Guided:G/Automatic:a) " ga
    case $ga in
        [Gg]|"" ) echo "YO"; break;;
        [Aa]* ) break;;
        * ) echo "Please answer "G" or "a"."
            echo ""
    esac
done
