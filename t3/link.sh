#!/usr/bin/env bash
# Links shared T3 Code config from ~/.config/t3 into ~/.t3/userdata. Existing files are backed up as *.bak.
set -euo pipefail
src="$HOME/.config/t3"
dst="$HOME/.t3/userdata"
mkdir -p "$dst"
for name in keybindings.json settings.json client-settings.json themes; do
  target="$dst/$name"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    mv "$target" "$target.bak"
  fi
  ln -s "$src/$name" "$target"
done
