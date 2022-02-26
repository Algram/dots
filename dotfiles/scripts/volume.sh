#!/usr/bin/env bash

# Utility for volume control and a notification popup with mako.
# 
# Examples:
# ./volume up       -->			Increase volume by 5
# ./volume down     -->			Decrease volume by 5
# ./volume mute     -->			Mute

function send_notification {
  volume=$(pamixer --get-volume)

  if [ "$volume" -eq 100 ]; then
    bar="墳"
  elif [ "$volume" -gt 98 ]; then
    bar="墳"
  elif [ "$volume" -gt 91 ]; then
    bar="墳"
  elif [ "$volume" -gt 84 ]; then
    bar="墳"
  elif [ "$volume" -gt 77 ]; then
    bar="墳"
  elif [ "$volume" -gt 70 ]; then
    bar="墳"
  elif [ "$volume" -gt 63 ]; then
    bar="墳"
  elif [ "$volume" -gt 56 ]; then
    bar="墳"
  elif [ "$volume" -gt 49 ]; then
    bar="奔"
  elif [ "$volume" -gt 42 ]; then
    bar="奔"
  elif [ "$volume" -gt 35 ]; then
    bar="奔"
  elif [ "$volume" -gt 28 ]; then
    bar="奔"
  elif [ "$volume" -gt 21 ]; then
    bar="奄"
  elif [ "$volume" -gt 14 ]; then
    bar="奄"
  elif [ "$volume" -gt 7 ]; then
    bar="奄"
  elif [ "$volume" -gt 0 ]; then
    bar="奄"
  else
    bar="奄"
  fi

  # Send the volume indicator notification with mako
  # /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --replace-file=/home/raphael/.temp/sound --hint=int:value:"$volume" "$bar $volume"
  /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --replace-file=/home/raphael/.temp/sound -i /home/raphael/Downloads/volume-up-solid.svg --hint=int:value:"$volume" "$volume"
}

case "$1" in
  up)
    pamixer -u
    pamixer -i 5

    send_notification
  ;;
  down)
    pamixer -u
    pamixer -d 5

    send_notification
  ;;
  mute)
    pamixer -t

    if pamixer --get-mute; then
      /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --replace-file=/home/raphael/.temp/sound "婢 Mute"
    else
      send_notification
    fi
  ;;
esac
