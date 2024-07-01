#!/usr/bin/env bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to install Hyprland plugins|--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

hyprpm update # Update hyprpm and install hyprland headers
hyprpm add https://github.com/ReshetnikovPavel/Hyprspace # Install the hyprspace plugin
hyprpm enable Hyprspace # Enable the hyprspace plugin
