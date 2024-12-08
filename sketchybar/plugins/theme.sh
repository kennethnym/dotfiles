#!/bin/sh

query=$(defaults read -g AppleInterfaceStyle | xargs)

if [ "$query" = "Dark" ]; then
	sketchybar --bar color=0xff232136 \
		         --set '/.*/' icon.color=0xffe0def4 label.color=0xffe0def4
else
	sketchybar --bar color=0xfffaf4ed \
		         --set '/.*/' icon.color=0xff575279 label.color=0xff575279
fi

