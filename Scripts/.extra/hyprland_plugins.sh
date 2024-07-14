#!/usr/bin/env bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to install Hyprland plugins|--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

# Set varables
scrDir=$(dirname "$(realpath "$0")")


source "${scrDir}/../global_fn.sh"
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

CfgLst="${1:-"${scrDir}/hyprland_plugins.lst"}"


# Updating
hyprpm update # Update hyprpm and install hyprland headers

# Installing plugins
cat "${CfgLst}" | while read lst; do

    name=$(echo "${lst}" | awk -F '|' '{print $1}')
    repo=$(echo "${lst}" | awk -F '|' '{print $2}')

    
    if [ -z "$(hyprpm list | grep -A 1 "Plugin ${name}" | grep true)" ]; then
        hyprpm add "$repo" # Install the hyprspace plugin
        hyprpm enable "$name" # Enable the hyprspace plugin
    fi

done

