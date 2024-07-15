#!/usr/bin/env sh


# set variables

scrDir=`dirname "$(realpath "$0")"`
source $scrDir/globalcontrol.sh

if [ $# -eq 0 ] ; then
    echo "usage: ./spotify.sh <spotify-title>"
    exit 1
else
    spotifyTitle="$1"
fi


hyprctl dispatch focusworkspaceoncurrentmonitor 10

if [ -z "$(hyprctl clients | grep "$spotifyTitle" | grep -v "grep" | grep -v "./spotify.sh")" ]; then
    hyprctl dispatch movecursor 0 0 

    kitty --title "spotify cava" sh -c "exit"
    kitty --title "spotify cava" sh -c "cava" &
    sleep 0.5
    hyprctl --batch "dispatch resizeactive exact 50% 55% ;  dispatch centerwindow 1 ; dispatch moveactive 70% 60%"
    

    spotify &
    sleep 1
    hyprctl --batch "dispatch resizeactive exact 50% 55% ; dispatch centerwindow 1 ; dispatch moveactive -70% -60%"
    
    sleep 3
    playerctl play-pause
fi