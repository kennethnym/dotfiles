#!/bin/bash
set -euo pipefail

# Parse flags like: ./install.sh macos=1 linux=1
for arg in "$@"; do declare "$arg"='1'; done

# Determine OS if not explicitly provided
if [[ "$(uname -s)" == "Darwin" ]]; then
  macos="${macos:-1}"
  linux="${linux:-}"
else
  linux="${linux:-1}"
  macos="${macos:-}"
fi

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_neovim_linux() {
  # Install latest stable Neovim from GitHub releases (official tarball)
  local arch tmp url
  arch="$(uname -m)"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  case "$arch" in
    x86_64|amd64) url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" ;;
    aarch64|arm64) url="https://github.com/neovim/neovim/releases/latest/download/nvim-linuxarm64.tar.gz" ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      return 1
      ;;
  esac

  # -f: fail on HTTP errors, -L: follow redirects, -S: show errors
  curl -fL --retry 3 --retry-delay 1 -o "$tmp/nvim.tar.gz" "$url"

  # quick sanity check (avoids "not in gzip format")
  if ! tar -tzf "$tmp/nvim.tar.gz" >/dev/null 2>&1; then
    echo "Downloaded file is not a valid gzip tarball: $url" >&2
    echo "First bytes:" >&2
    head -c 200 "$tmp/nvim.tar.gz" | sed -e 's/[^[:print:]\t]/./g' >&2
    return 1
  fi

  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"

  # tarball extracts to /opt/nvim-linux64 or /opt/nvim-linuxarm64
  local extracted
  extracted="$(tar -tzf "$tmp/nvim.tar.gz" | head -n1 | cut -d/ -f1)"
  sudo mv "/opt/$extracted" /opt/nvim

  sudo mkdir -p /usr/local/bin
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
}

install_neovim_macos() {
  if need_cmd brew; then
    brew install neovim
  else
    echo "Homebrew not found. Install brew or neovim manually." >&2
    return 1
  fi
}

ensure_neovim() {
  if need_cmd nvim; then
    return 0
  fi

  echo "neovim not found; installing..."
  if [[ -n "${linux:-}" ]]; then
    install_neovim_linux
  else
    install_neovim_macos
  fi
}

# --- Ensure nvim installed before linking config ---
ensure_neovim

# install neovim config
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim" || :
fi

# install starship config
mkdir -p "$HOME/.config"
ln -s "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml" || :

if [ ! -n "${linux:-}" ]; then
  ln -s "$HOME/dotfiles/aerospace.toml" "$HOME/.aerospace.toml" || :

  for d in sketchybar borders neovide ghostty; do
    [ -d "$HOME/.config/$d" ] || ln -s "$HOME/dotfiles/$d" "$HOME/.config/$d" || :
  done
else
  for d in sway waybar rofi dunst; do
    [ -d "$HOME/.config/$d" ] || ln -s "$HOME/dotfiles/$d" "$HOME/.config/$d" || :
  done
fi

