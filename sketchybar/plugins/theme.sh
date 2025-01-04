#!/bin/sh

query=$(defaults read -g AppleInterfaceStyle | xargs)

if [ "$query" = "Dark" ]; then
	sketchybar --bar color=0xff313244 \
		         --set '/.*/' icon.color=0xffcdd6f4 label.color=0xffcdd6f4
else
	sketchybar --bar color=0xffeff1f5 \
		         --set '/.*/' icon.color=0xff4c4f69 label.color=0xff4c4f69
fi

