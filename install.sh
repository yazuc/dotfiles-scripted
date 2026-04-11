#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# CONFIG FOLDERS
CONFIG_DIRS=(
  hypr
  kitty
  fish
  rofi
  waybar
  dunst
  wlogout
)

mkdir -p "$HOME/.config"

for dir in "${CONFIG_DIRS[@]}"; do
  if [ -d "$DOTFILES_DIR/$dir" ]; then
    echo "Copying $dir..."
    rm -rf "$HOME/.config/$dir"
    cp -r "$DOTFILES_DIR/$dir" "$HOME/.config/"
  fi
done

# CURSORS
if [ -d "$DOTFILES_DIR/FernCursor" ]; then
  echo "Installing cursor..."
  mkdir -p "$HOME/.icons"
  rm -rf "$HOME/.icons/FernCursor"
  cp -r "$DOTFILES_DIR/FernCursor" "$HOME/.icons/"
fi

# SDDM THEME (requires sudo)
if [ -d "$DOTFILES_DIR/Makima-SDDM" ]; then
  echo "Installing SDDM theme (sudo required)..."
  sudo rm -rf /usr/share/sddm/themes/Makima-SDDM
  sudo cp -r "$DOTFILES_DIR/Makima-SDDM" /usr/share/sddm/themes/
fi

# SDDM CONFIG
if [ -f "$DOTFILES_DIR/sddm.conf" ]; then
  echo "Installing sddm.conf (sudo required)..."
  sudo cp "$DOTFILES_DIR/sddm.conf" /etc/sddm.conf
fi

if [ -f "$DOTFILES_DIR/packages.txt" ]; then
  echo "Installing packages..."
  sudo pacman -S --needed - <"$DOTFILES_DIR/packages.txt"
fi

echo "Done."
