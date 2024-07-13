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
    kitty --title "spotify cava" sh -c "cava" &
    sleep 0.3
    hyprctl --batch "dispatch focuswindow cava ; dispatch togglefloating"
    hyprctl --batch "dispatch focuswindow cava ; dispatch resizeactive exact 50% 55%"
    hyprctl --batch "dispatch focuswindow cava ; dispatch centerwindow 1"
    hyprctl --batch "dispatch focuswindow cava ; dispatch moveactive 70% 60%"

    spotify &
    sleep 1
    hyprctl --batch "dispatch focuswindow initialTitle:^($spotifyTitle)$ ; dispatch resizeactive exact 50% 55%"
    hyprctl --batch "dispatch focuswindow initialTitle:^($spotifyTitle)$ ; dispatch centerwindow 1"
    hyprctl --batch "dispatch focuswindow initialTitle:^($spotifyTitle)$ ; dispatch moveactive -70% -60%"

    sleep 3
    playerctl play-pause
fi