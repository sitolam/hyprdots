#!/usr/bin/env sh

# Restores the shader after screenhot has been taken
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

# Saves the current shader and turns it off
save_shader() {
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}

save_shader # Saving the current shader



XDG_CURRENT_DESKTOP="Sway"



function print_error
{
	cat <<"EOF"
    ./flameshot.sh <action>
    ...valid actions are...
        p  : print single screen
        s  : snip current screen
        d  : caputre entire desktop
EOF
}

case $1 in
p) # print single screen
	flameshot screen ;;
s) # drag to manually snip an area / click on a window to print it
	flameshot gui ;;
d) # print every output
	flameshot full ;;
*) # invalid option
	print_error ;;
esac

