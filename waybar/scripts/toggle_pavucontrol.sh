#!/bin/bash

if hyprctl clients | grep "org.pulseaudio.pavucontrol"; then
    pkill pavucontrol
    exit
fi

# Launch pavucontrol in background
pavucontrol &

# Get PID
PID=$!

# Wait until it has a window
while ! hyprctl clients | grep "org.pulseaudio.pavucontrol"; do
    sleep 0.05
done

# Continuously check if it lost focus
while kill -0 $PID 2>/dev/null; do
    FOCUSED=$(hyprctl activewindow -j | jq -r '.class')

    if [[ "$FOCUSED" != "org.pulseaudio.pavucontrol" ]]; then
        kill $PID
        exit 0
    fi

    sleep 0.1
done