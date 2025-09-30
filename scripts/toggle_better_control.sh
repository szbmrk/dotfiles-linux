#!/bin/bash

if hyprctl clients | grep "better_control.py"; then
    pkill better-control
fi

if [ -z "$1" ]; then
    better-control &
else 
    better-control -$1 &
fi

PID=$!

# Wait until it has a window
while ! hyprctl clients | grep "better_control.py"; do
    sleep 0.05
done

while kill -0 $PID 2>/dev/null; do
    FOCUSED=$(hyprctl activewindow -j | jq -r '.class')

    echo $FOCUSED
    if [[ "$FOCUSED" != "better_control.py" ]]; then
        kill $PID
        exit 0
    fi

    sleep 0.1
done
