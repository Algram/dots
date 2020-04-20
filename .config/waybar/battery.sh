#!/bin/zsh

BATTERY_LEVEL=$(dbus-send --print-reply --system --dest="io.github.openrazer1" /io/github/openrazer1/devices/PM1950H12301836 io.github.openrazer1.Device.getBatteryLevel | grep -oP 'uint16\s*\K\d+')

BATTERY_PERCENTAGE=$(echo "scale=2;($BATTERY_LEVEL/255)*100" | bc)

echo ${BATTERY_PERCENTAGE%.*}%