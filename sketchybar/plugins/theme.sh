#!/bin/sh

query=$(defaults read -g AppleInterfaceStyle | xargs)

if [ "$query" = "Dark" ]; then
	sketchybar --bar color=0x00000000 \
		         --set '/.*/' icon.color=0xffffffff label.color=0xffffffff
else
	sketchybar --bar color=0x00000000 \
		         --set '/.*/' icon.color=0xffffffff label.color=0xffffffff
fi

