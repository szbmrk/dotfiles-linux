#!/bin/bash

count=$(swaync-client -c)

dnd=$(swaync-client -D)

if [[ "$dnd" == "true" ]]; then
    icon="󰂛"
else
    icon="󰂚"
fi

echo "{\"text\": \"$icon $count\", \"tooltip\": \"Notifications: $count | DND: $dnd\"}"
