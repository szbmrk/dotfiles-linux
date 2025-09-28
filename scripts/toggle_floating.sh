#!/bin/bash

if hyprctl activewindow -j | grep -q '"floating": true'; then
    hyprctl dispatch togglefloating
else
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 1600 900
    hyprctl dispatch centerwindow
fi
