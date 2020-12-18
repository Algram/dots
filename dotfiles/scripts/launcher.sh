#!/usr/bin/env bash

# Utility for starting different launchers

if [ "$1" == "clipboard" ]; then
  clipman pick --tool "rofi" --tool-args="-l 8"
elif [ "$1" == "gopass" ]; then
  gopass ls --flat | rofi -dmenu -p gopass | xargs --no-run-if-empty gopass show -o | head -n 1 | sudo ydotool type --file -
elif [ "$1" == "emoji" ]; then
  rofi -show emoji -modi emoji -matching normal
else
  rofi -plugin-path /usr/local/lib/rofi -show drun -no-show-match -no-sort -show-icons
fi
