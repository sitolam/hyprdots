#!/usr/bin/env bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to install Hyprland plugins|--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

hyprpm update # Update hyprpm and install hyprland headers

hyprpm list | grep -A 1 "Plugin Hyprspace" | grep true
if [ $? -eq 0 ]; then
    hyprpm add https://github.com/ReshetnikovPavel/Hyprspace # Install the hyprspace plugin
    hyprpm enable Hyprspace # Enable the hyprspace plugin
fi
