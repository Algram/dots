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

# pactl info
# pactl list sinks short

if [ "$1" == "disable" ]; then
  # pkill -SIGINT wf-recorder
  # pkill -SIGINT hyperiond
  pkill -SIGINT hyperhdr
  swaymsg "[workspace=1]" move workspace to output DP-1
  swaymsg output HDMI-A-1 disable
  # pkill -SIGINT obs
  pactl set-default-sink alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo
elif [ "$1" == "enable" ]; then
  /nix/store/kpxc35wclp0rmd8w6gwnfdzhj8lpz7l7-xdg-desktop-portal-wlr-0.7.0/libexec/xdg-desktop-portal-wlr -r -lTRACE -c /etc/nixos/dotfiles/scripts/wlr-config.conf &
  # /nix/store/8mz832r18lhr5dbr8b3djhhp5ypyb5yv-xdg-desktop-portal-wlr-0.6.0/libexec/xdg-desktop-portal-wlr -r -lTRACE -c /etc/nixos/dotfiles/scripts/wlr-config.conf &
  sleep 1

  swaymsg output HDMI-A-1 enable
  swaymsg "[workspace=1]" move workspace to output HDMI-A-1
  sleep 1
  # Output file "/dev/video9" exists. Overwrite? Y/n:
  # sudo v4l2loopback-ctl set-fps /dev/video9 60
  # yes | wf-recorder -c rawvideo -o HDMI-A-1 -m v4l2 -x yuv420p -F scale=352x198,setsar=1:1 -r 60 -D -t -f /dev/video9 &
  # sleep 1
  # /home/raphael/Downloads/nixpkgs/result/bin/hyperiond &
  /home/raphael/Downloads/nixpkgs/result/bin/hyperhdr &
  sleep 1
  # env QT_QPA_PLATFORM=wayland obs
  pactl set-default-sink alsa_output.pci-0000_0c_00.4.analog-surround-51
  # pactl set-default-sink alsa_output.pci-0000_0c_00.4.iec958-stereo
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