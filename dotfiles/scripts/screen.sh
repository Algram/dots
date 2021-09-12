#!/usr/bin/env bash

# Utility for grim/slurp as a screenshot/color picker tool

record_area() {
  if [ -n "$(pgrep "wf-recorder")" ]; then
    pkill -SIGINT wf-recorder
    notify-send "Stopped recording"
  else
    notify-send "Started recording"
    wf-recorder -g "$(slurp -w 0 -b 00000066)" -f ~/Videos/$(date +%s).mp4
  fi
}

if [ "$1" == "area" ]; then
  grim -g "$(slurp -w 0 -b 00000066)" - | wl-copy -t image/png
elif [ "$1" == "annotate" ]; then
  grim -g "$(slurp -w 0 -b 00000066)" - | swappy -f - -o - | wl-copy -t image/png
elif [ "$1" == "record_area" ]; then
  record_area
elif [ "$1" == "window" ]; then
  swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -g "$(slurp -w 0 -b 00000066)" ~/Pictures/$(date +%s).png
elif [ "$1" == "color" ]; then
  var=$(grim -g "$(slurp -p -b 00000000)" -t ppm - | convert - -format '#%[hex:u]' info:-)
  hex=$(echo $var | cut -d' ' -f1)
  rgb=$(echo $var | cut -d' ' -f2 | sed 's/srgb(//' | sed 's/,/, /g' | sed 's/)//')

  convert -size 100x60 xc:"$hex" $HOME/.cache/color.jpg

  wl-copy "$hex"

  notify-send -i $HOME/.cache/color.jpg "$hex" "$rgb"
fi

# https://jan-sl.de/itryarch/screenshots/