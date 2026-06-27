#!/usr/bin/env bash

CONF="$HOME/.config/MangoHud/MangoHud.conf"

if grep -q '^preset=-1$' "$CONF"; then
  sed -i 's/^preset=-1$/preset=1/' "$CONF"
else
  sed -i 's/^preset=1$/preset=-1/' "$CONF"
fi
