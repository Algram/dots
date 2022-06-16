#!/usr/bin/env bash

# ALPHA

# mosquitto_sub -R -h 192.168.1.152 -t cinema/toggle | while read RAW_DATA

# do
#  sh /etc/nixos/dotfiles/scripts/tv.sh
# done

# if swaymsg -t get_outputs -r | jq -e '.[] | select(.name=="HDMI-A-1") | .active' > /dev/null ; then
#   swaymsg "[workspace=1]" move workspace to output DP-1
#   swaymsg output HDMI-A-1 disable
#   pactl set-default-sink alsa_output.pci-0000_0c_00.4.analog-stereo
#   sh /etc/nixos/dotfiles/scripts/screenshare.sh
# else
#   swaymsg output HDMI-A-1 enable
#   swaymsg "[workspace=1]" move workspace to output HDMI-A-1

#   pactl set-default-sink alsa_output.pci-0000_0a_00.1.hdmi-stereo
#   sh /etc/nixos/dotfiles/scripts/screenshare.sh
# fi


if [ "$1" == "disable" ]; then
  swaymsg "[workspace=1]" move workspace to output DP-1
  swaymsg output HDMI-A-1 disable
  pkill -SIGINT obs
  pkill -SIGINT hyperiond
  pactl set-default-sink alsa_output.pci-0000_0c_00.4.analog-stereo
elif [ "$1" == "enable" ]; then
  swaymsg output HDMI-A-1 enable
  swaymsg "[workspace=1]" move workspace to output HDMI-A-1
  hyperiond &
  env QT_QPA_PLATFORM=xcb obs
  pactl set-default-sink alsa_output.pci-0000_0a_00.1.hdmi-stereo
fi


# IF HDMI enabled
# disable it
# swaymsg "[workspace=1]" move workspace to output DP-1
# audio switch
# if tv on press on/off button
# stop obs/hyperion
#
# ELSE
# enable it
# swaymsg "[workspace=1]" move workspace to output HDMI-A-1
# audio switch
# if tv off press on/off button
# start obs/hyperion