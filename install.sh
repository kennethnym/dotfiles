#!/bin/bash

# install wezterm config
ln -s "$HOME/dotfiles/.wezterm.lua" "$HOME/.wezterm.lua"

# install neovim config
if [ ! -d "$HOME/.config/nvim" ]; then
	mkdir -p "$HOME/.config/nvim"
	ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
fi

# install starship config
ln -s "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"

# install goneovim config
mkdir -p "$HOME/.config/goneovim"
ln -s "$HOME/dotfiles/goneovim.toml" "$HOME/.config/goneovim/settings.toml"

# install aerospace config
ln -s "$HOME/dotfiles/aerospace.toml" "$HOME/.aerospace.toml"
