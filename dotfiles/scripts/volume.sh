#!/usr/bin/env bash

# Utility for volume control and a notification popup with mako.
# 
# Examples:
# ./volume up       -->			Increase volume by 5
# ./volume down     -->			Decrease volume by 5
# ./volume mute     -->			Mute

function get_volume {
  amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

function is_mute {
  amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

function send_notification {
  volume=$(get_volume)

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
  /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --replace-file=/tmp/.sound --hint=int:value:"$volume" "$bar $volume"
}

case "$1" in
  up)
    amixer set Master on > /dev/null &
    amixer sset Master 5%+ > /dev/null

    # Play the freedesktop volume change sound
    # play /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &

    send_notification
  ;;
  down)
    amixer set Master on > /dev/null &
    amixer sset Master 5%- > /dev/null

    # Play the freedesktop volume change sound
    # play /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &

    send_notification
  ;;
  mute)
    amixer set Master 1+ toggle > /dev/null

    if is_mute; then
      /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --replace-file=/tmp/.sound "婢 Mute"
    else
      # Play the freedesktop volume change sound
      # play /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &

      send_notification
    fi
  ;;
esac
