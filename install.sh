#!/bin/bash

set -eu

for arg in "$@"; do declare $arg='1'; done

install_neovim() {
	if command -v nvim &> /dev/null; then
		echo "neovim is already installed: $(nvim --version | head -1)"
		return 0
	fi

	echo "Installing neovim..."

	local os arch filename url
	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)

	case "$os" in
		linux)
			case "$arch" in
				x86_64) filename="nvim-linux-x86_64.tar.gz" ;;
				aarch64|arm64) filename="nvim-linux-arm64.tar.gz" ;;
				*) echo "Unsupported architecture: $arch"; return 1 ;;
			esac
			;;
		darwin)
			case "$arch" in
				x86_64) filename="nvim-macos-x86_64.tar.gz" ;;
				arm64) filename="nvim-macos-arm64.tar.gz" ;;
				*) echo "Unsupported architecture: $arch"; return 1 ;;
			esac
			;;
		*)
			echo "Unsupported OS: $os"
			return 1
			;;
	esac

	url="https://github.com/neovim/neovim/releases/latest/download/$filename"
	local tmpdir
	tmpdir=$(mktemp -d)
	trap "rm -rf $tmpdir" EXIT

	echo "Downloading $url..."
	curl -fsSL "$url" -o "$tmpdir/$filename"

	echo "Extracting to /usr/local..."
	tar -xzf "$tmpdir/$filename" -C "$tmpdir"

	local extracted_dir
	extracted_dir=$(find "$tmpdir" -maxdepth 1 -type d -name 'nvim-*' | head -1)

	if [ -w /usr/local ]; then
		cp -r "$extracted_dir"/* /usr/local/
	else
		sudo cp -r "$extracted_dir"/* /usr/local/
	fi

	echo "neovim installed: $(nvim --version | head -1)"
}

install_neovim

if [[ ! -n macos ]];
  then linux=1;
else
	linux="";
fi

# install asdf tool-versions
ln -s "$HOME/dotfiles/.tool-versions" "$HOME/.tool-versions" || :

# install wezterm config
ln -s "$HOME/dotfiles/.wezterm.lua" "$HOME/.wezterm.lua" || :

# install neovim config
if [ ! -d "$HOME/.config/nvim" ]; then
	ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim" || :
fi

if [ ! -d "$HOME/.config/zed/settings.json" ]; then
	ln -s "$HOME/dotfiles/zed" "$HOME/.config/zed" || :
fi

# install starship config
ln -s "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml" || :

if [ ! -n "$linux" ]; then
	# install aerospace config
	ln -s "$HOME/dotfiles/aerospace.toml" "$HOME/.aerospace.toml" || :

	if [ ! -d "$HOME/.config/sketchybar" ]; then
		ln -s "$HOME/dotfiles/sketchybar" "$HOME/.config/sketchybar" || :
	fi

	if [ ! -d "$HOME/.config/borders" ]; then
		ln -s "$HOME/dotfiles/borders" "$HOME/.config/borders" || :
	fi

	if [ ! -d "$HOME/.config/neovide" ]; then
		ln -s "$HOME/dotfiles/neovide" "$HOME/.config/neovide" || :
	fi

	if [ ! -d "$HOME/.config/ghostty" ]; then
		ln -s "$HOME/dotfiles/ghostty" "$HOME/.config/ghostty" || :
	fi
else
	# install sway
	if [ ! -d "$HOME/.config/sway" ]; then
		ln -s "$HOME/dotfiles/sway" "$HOME/.config/sway" || :
	fi

	# install waybar
	if [ ! -d "$HOME/.config/waybar" ]; then
		ln -s "$HOME/dotfiles/waybar" "$HOME/.config/waybar" || :
	fi

	# install rofi
	if [ ! -d "$HOME/.config/rofi" ]; then
		ln -s "$HOME/dotfiles/rofi" "$HOME/.config/rofi" || :
	fi

	# install rofi
	if [ ! -d "$HOME/.config/dunst" ]; then
		ln -s "$HOME/dotfiles/dunst" "$HOME/.config/dunst" || :
	fi
fi
