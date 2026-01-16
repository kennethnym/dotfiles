#!/bin/bash
set -euo pipefail

for arg in "$@"; do
  # allows: ./install.sh macos   (sets $macos=1)
  declare "${arg}=1"
done

if [[ -n "${macos:-}" ]]; then
  linux=""
else
  linux=1
fi

install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    return 0
  fi

  if [[ -z "${linux:-}" ]]; then
    # macOS
    if command -v brew >/dev/null 2>&1; then
      brew install neovim
      return 0
    fi
    echo "Neovim not found and Homebrew is not installed. Install Homebrew or install Neovim manually." >&2
    return 1
  fi

  # Linux (curl-based install, NOT AppImage): download official tarball and install into ~/.local
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Neovim on Linux." >&2
    return 1
  fi

  arch="$(uname -m)"
  case "$arch" in
    x86_64) nvim_arch="linux-x86_64" ;;
    aarch64|arm64) nvim_arch="linux-arm64" ;;
    *)
      echo "Unsupported architecture for tarball install: $arch" >&2
      return 1
      ;;
  esac

  base="$HOME/.local"
  mkdir -p "$base/bin"

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  # Stable release tarball (change v* URL if you want nightly)
  url="https://github.com/neovim/neovim/releases/latest/download/nvim-${nvim_arch}.tar.gz"
  curl -fsSL "$url" -o "$tmpdir/nvim.tar.gz"

  tar -xzf "$tmpdir/nvim.tar.gz" -C "$tmpdir"

  # The extracted folder is named nvim-linux-<arch>
  src_dir="$tmpdir/nvim-${nvim_arch}"

  # Install by replacing ~/.local/nvim
  rm -rf "$base/nvim"
  mv "$src_dir" "$base/nvim"

  # Symlink binary into ~/.local/bin
  ln -sf "$base/nvim/bin/nvim" "$base/bin/nvim"

  if ! printf '%s' "${PATH:-}" | tr ':' '\n' | grep -qx "$base/bin"; then
    echo "Installed nvim to $base/bin/nvim. Ensure $base/bin is in your PATH." >&2
  fi
}

mkdir -p "$HOME/.config"

# install neovim if missing
install_neovim

# install neovim config
if [ ! -d "$HOME/.config/nvim" ]; then
  ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim" || :
fi

# install starship config
ln -s "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml" || :

if [ ! -n "${linux:-}" ]; then
  # macos-only configs
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
  # linux-only configs
  if [ ! -d "$HOME/.config/sway" ]; then
    ln -s "$HOME/dotfiles/sway" "$HOME/.config/sway" || :
  fi
  if [ ! -d "$HOME/.config/waybar" ]; then
    ln -s "$HOME/dotfiles/waybar" "$HOME/.config/waybar" || :
  fi
  if [ ! -d "$HOME/.config/rofi" ]; then
    ln -s "$HOME/dotfiles/rofi" "$HOME/.config/rofi" || :
  fi
  if [ ! -d "$HOME/.config/dunst" ]; then
    ln -s "$HOME/dotfiles/dunst" "$HOME/.config/dunst" || :
  fi
fi

