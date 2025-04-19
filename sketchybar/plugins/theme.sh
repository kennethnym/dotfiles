#!/bin/sh

query=$(defaults read -g AppleInterfaceStyle | xargs)

if [ "$query" = "Dark" ]; then
	sketchybar --bar color=0xff313244 \
		         --set '/.*/' icon.color=0xffffffff label.color=0xffffffff
else
	sketchybar --bar color=0x00eff1f5 \
		         --set '/.*/' icon.color=0x80000000 label.color=0x80000000
fi

