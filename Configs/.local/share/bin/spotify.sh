#!/usr/bin/env sh

# set variables

scrDir=`dirname "$(realpath "$0")"`
source $scrDir/globalcontrol.sh

kitty --title "spotify cava" sh -c "cava" &
sleep 0.3
hyprctl --batch "dispatch focuswindow cava ; dispatch togglefloating ; dispatch resizeactive exact 50% 55% ; dispatch centerwindow 1 ; dispatch moveactive 70% 60%" 

spotify &
sleep 1
hyprctl --batch "dispatch focuswindow initialTitle:^(Spotify Premium)$ ; dispatch resizeactive exact 50% 55% ; dispatch centerwindow 1 ; dispatch moveactive -70% -60%" 

sleep 3
playerctl play-pause