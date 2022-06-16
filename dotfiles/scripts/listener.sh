#!/usr/bin/env bash

# ALPHA

mosquitto_sub -R -h 192.168.1.152 -t command/tv_scene | while read PAYLOAD

do
  if [ "$PAYLOAD" == "off" ]; then
      echo "DISABLING"
      sh /etc/nixos/dotfiles/scripts/tv.sh disable &
    elif [ "$PAYLOAD" == "on" ]; then
      sh /etc/nixos/dotfiles/scripts/tv.sh enable &
    fi
done
