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
temp_screenshot="/tmp/screenshot.png"
temp_content_tes="/tmp/content"
temp_content="/tmp/content.txt"

rm $temp_screenshot
rm $temp_content_tes
rm $temp_content
content=""

function print_error
{
	cat <<"EOF"
    ./flameshot.sh <action>
    ...valid actions are...
        p  : print single screen
        s  : snip current screen
        d  : caputre entire desktop
		o  : use OCR on selection
EOF
}

case $1 in
p) # print single screen
	flameshot screen && restore_shader ;;
s) # drag to manually snip an area / click on a window to print it
	flameshot gui && restore_shader ;;
d) # print every output
	flameshot full ;;
o) # use ocr
	grimblast copysave area $temp_screenshot && restore_shader
	tesseract $temp_screenshot $temp_content_tes && content=$(< $temp_content)
	if [ -n "$content" ]; then
		wl-copy $content
		notify-send -a "t1" -i "$temp_screenshot" "$content"
	else
		notify-send -a "t1" -i "$temp_screenshot" "failed to copy, try again"
    fi ;;

*) # invalid option
	print_error ;;
esac

