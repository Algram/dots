#!/usr/bin/env bash

# ALPHA

mosquitto_sub -R -h 192.168.1.152 -t cinema/toggle | while read RAW_DATA

do
 sh /etc/nixos/dotfiles/scripts/tv.sh
done

if swaymsg -t get_outputs -r | jq -e '.[] | select(.name=="HDMI-A-1") | .active' > /dev/null ; then
  swaymsg "[workspace=1]" move workspace to output DP-1
  swaymsg output HDMI-A-1 disable
  pactl set-default-sink alsa_output.pci-0000_0c_00.4.analog-stereo
else
  swaymsg output HDMI-A-1 enable
  swaymsg "[workspace=1]" move workspace to output HDMI-A-1

  pactl set-default-sink alsa_output.pci-0000_0a_00.1.hdmi-stereo
fi
