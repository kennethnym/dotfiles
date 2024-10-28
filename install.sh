#!/bin/bash

set -eu
for arg in "$@"; do declare $arg=1; done

if [ ! -v macos ]; then linux=1; fi

# install wezterm config
ln -s "$HOME/dotfiles/.wezterm.lua" "$HOME/.wezterm.lua"

# install neovim config
if [ ! -d "$HOME/.config/nvim" ]; then
	ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
fi

# install starship config
ln -s "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"

if [ ! -v linux ]; then
	# install aerospace config
	ln -s "$HOME/dotfiles/aerospace.toml" "$HOME/.aerospace.toml"
else
	# install sway
	if [ ! -d "$HOME/.config/sway" ]; then
		ln -s "$HOME/dotfiles/sway" "$HOME/.config/sway"
	fi

	# install waybar
	if [ ! -d "$HOME/.config/waybar" ]; then
		ln -s "$HOME/dotfiles/waybar" "$HOME/.config/waybar"
	fi

	# install rofi
	if [ ! -d "$HOME/.config/rofi" ]; then
		ln -s "$HOME/dotfiles/rofi" "$HOME/.config/rofi"
	fi

	# install rofi
	if [ ! -d "$HOME/.config/dunst" ]; then
		ln -s "$HOME/dotfiles/dunst" "$HOME/.config/dunst"
	fi
fi
