#!/bin/bash

if hyprctl activewindow -j | grep -q '"floating": true'; then
    hyprctl dispatch togglefloating
else
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 1400 800
    hyprctl dispatch centerwindow
fi
