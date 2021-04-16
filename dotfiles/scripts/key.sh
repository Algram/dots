#!/usr/bin/env bash

# Utility for inserting any character with the compose key.
# This is useful for writing umlauts with an ANSI keyboard.
# 
# Examples:
# super + a         -->     ä
# super + shift + a -->     Ä
# super + s         -->     ß

unicode="0+0+e+4"

if [ "$2" == "ä" ]; then
  unicode="0+0+e+4"
elif [ "$2" == "Ä" ]; then
  unicode="0+0+c+4"
elif [ "$2" == "ö" ]; then
  unicode="0+0+f+6"
elif [ "$2" == "Ö" ]; then
  unicode="0+0+d+6"
elif [ "$2" == "ü" ]; then
  unicode="0+0+f+c"
elif [ "$2" == "Ü" ]; then
  unicode="0+0+d+c"
elif [ "$2" == "ß" ]; then
  unicode="0+0+d+f"
fi

is_wayland=$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.focused) | .app_id | type | contains("string")')

if [ "$is_wayland" == true ]; then
  wtype $2
else
  xdotool type $2
fi
