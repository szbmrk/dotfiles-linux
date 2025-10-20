#!/usr/bin/env bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle
ffplay -nodisp -autoexit /home/szobo/SoundEffects/discordmute.mp3
