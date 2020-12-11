#!/usr/bin/env bash

BATTERY_PERCENTAGE=$(dbus-send --print-reply --session --dest="org.razer" /org/razer/device/PM1950H12301836 razer.device.power.getBattery  | grep -oP 'double\s*\K\d+')

echo ${BATTERY_PERCENTAGE%.*}%