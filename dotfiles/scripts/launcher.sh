#!/usr/bin/env bash

# Utility for starting different launchers

if [ "$1" == "clipboard" ]; then
  clipman pick --tool "wofi" --tool-args="-l 8 -kb-cancel 'Super+g,Escape'"
elif [ "$1" == "gopass" ]; then
  # TODO: Switch to check for xwayland and wayland the same way it is done in key.sh
  gopass ls --flat | wofi -kb-cancel 'Super+b,Escape' -dmenu -p  | xargs --no-run-if-empty gopass show -o | head -n 1 | wtype -
  # gopass ls --flat | walker --dmenu | xargs --no-run-if-empty gopass show -o | head -n 1 | wtype -
  # keepmenu
  # ./keepass.sh
else
      # wofi -show drun -no-show-match -no-sort -show-icons -kb-cancel 'Super+space,Escape'
      wofi
      # walker
fi
