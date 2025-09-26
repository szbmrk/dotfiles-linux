#!/usr/bin/env bash

rofi -show drun &
ROFI_PID=$!

CURRENT_WS=$(hyprctl activeworkspace | awk 'NR==1 {print $3}')

while kill -0 $ROFI_PID 2>/dev/null; do
    NEW_WS=$(hyprctl activeworkspace | awk 'NR==1 {print $3}')
    echo "Current workspace: $CURRENT_WS, New workspace: $NEW_WS"
    if [[ "$NEW_WS" != "$CURRENT_WS" ]]; then
        kill $ROFI_PID 2>/dev/null
        break
    fi
    sleep 0.1
done
