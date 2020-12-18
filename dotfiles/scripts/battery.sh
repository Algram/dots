#!/usr/bin/env bash

DEVICE=$(dbus-send --print-reply --session --dest="org.razer" /org/razer razer.devices.getDevices  | grep -oP 'string\s*\K\"\K(?:(?!").)*' | tail -1);
BATTERY_PERCENTAGE=$(dbus-send --print-reply --session --dest="org.razer" /org/razer/device/${DEVICE} razer.device.power.getBattery  | grep -oP 'double\s*\K\d+')

echo ${BATTERY_PERCENTAGE%.*}%
