#!/usr/bin/env bash

DEVICE=$(dbus-send --print-reply --session --dest="org.razer" /org/razer razer.devices.getDevices  | grep -oP 'string\s*\K\"\K(?:(?!").)*' | tail -1);
BATTERY_PERCENTAGE=$(dbus-send --print-reply --session --dest="org.razer" /org/razer/device/${DEVICE} razer.device.power.getBattery  | grep -oP 'double\s*\K\d+')

if [ "$BATTERY_PERCENTAGE" == "0" ]; then
  PREVIOUS_BATTERY_PERCENTAGE=$(cat ~/.cache/battery-mouse)
  echo ${PREVIOUS_BATTERY_PERCENTAGE%.*}%
else
  echo $BATTERY_PERCENTAGE > ~/.cache/battery-mouse
  echo ${BATTERY_PERCENTAGE%.*}%
fi