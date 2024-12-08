#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     sketchybar --set $NAME background.drawing=on
# else
#     sketchybar --set $NAME background.drawing=off
# fi
#

get_app_icon () {
    local app_name="$1"

		if [ "$app_name" = "WezTerm" ]; then
		    echo "󰆍"
		elif [ "$app_name" = "neovide" ]; then
		    echo ""
		elif [ "$app_name" = "Firefox" ]; then
			  echo "󰈹"
		elif [ "$app_name" = "Discord" ]; then
			  echo "󰙯"
		elif [ "$app_name" = "Music" ]; then
			  echo "󰝚"
		elif [ "$app_name" = "WebStorm" ]; then
			  echo "󰈮"
		elif [ "$app_name" = "IntelliJ IDEA" ]; then
			  echo "󰈮"
		else
        echo "name:$app_name"
		fi
}

sketchybar --remove /app\\./

focused_window=$(aerospace list-windows --focused --format "%{window-id}" || "")
IFS=$'\n'
for item in $(aerospace list-windows --workspace focused --format "%{window-id}:%{app-name}"); do
	  window_id=${item%:*}
		app_name=${item#*:}
	  label=$(get_app_icon "$app_name")
	  if [ "${label:0:5}" = "name:" ]; then
				sketchybar --add item app.$window_id.$app_name left \
									 --set app.$window_id.$app_name \
									 label=${label:5}
		else
				sketchybar --add item app.$window_id.$app_name left \
									 --set app.$window_id.$app_name \
									 icon=$label
		fi
		
		if [ "$window_id" = "$focused_window" ]; then
			  sketchybar --set app.$window_id.$app_name icon.color=0xffea9a97
		fi
done
unset IFS

