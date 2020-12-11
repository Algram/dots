#!/usr/bin/env bash
 
# This script watches changes to brightness is a /sys/class/backlight directory
# and calls ddccontrol to send those changes to a ddc-brightness-capable monitor.
 
# You may need to install the inotify-tools in your distribution to get inotifywait,
# or comment it out to just run the script all the time.
 
# Test out using ddccontrol first with something like
# ddccontrol dev:/dev/i2c-4 -r 0x10 -w 50

function send_notification {
  volume=$(cat ~/.cache/brightness)

  if [ "$volume" -eq 100 ]; then
    bar=""
  elif [ "$volume" -gt 98 ]; then
    bar=""
  elif [ "$volume" -gt 91 ]; then
    bar=""
  elif [ "$volume" -gt 84 ]; then
    bar=""
  elif [ "$volume" -gt 77 ]; then
    bar=""
  elif [ "$volume" -gt 70 ]; then
    bar=""
  elif [ "$volume" -gt 63 ]; then
    bar=""
  elif [ "$volume" -gt 56 ]; then
    bar=""
  elif [ "$volume" -gt 49 ]; then
    bar=""
  elif [ "$volume" -gt 42 ]; then
    bar=""
  elif [ "$volume" -gt 35 ]; then
    bar=""
  elif [ "$volume" -gt 28 ]; then
    bar=""
  elif [ "$volume" -gt 21 ]; then
    bar=""
  elif [ "$volume" -gt 14 ]; then
    bar=""
  elif [ "$volume" -gt 7 ]; then
    bar=""
  elif [ "$volume" -gt 0 ]; then
    bar=""
  else
    bar=""
  fi

  # Send the volume indicator notification with mako
  /etc/nixos/dotfiles/scripts/external/notify-send.sh -t 1000 --hint=int:value:"$volume" "$bar $volume"
}

# Modify this function as needed to handle setting your monitor brightness
function ddcset {
  bgt=$(cat ~/.cache/brightness)
  # numberbgt=`expr $bgt + $1`
  numberbgt=$1

  if [ "$numberbgt" -lt 0 ]; then
    echo $numberbgt
    # sudo ddccontrol dev:/dev/i2c-4 -r 0x10 -w 0 1>&2 > /dev/null
    sudo ddcutil --noverify --bus 4 --sleep-multiplier 0.1 setvcp 10 0
    sudo ddcutil --noverify --bus 6 --sleep-multiplier 0.1 setvcp 10 0
  elif [ "$numberbgt" -gt 100 ]; then
    echo $numberbgt
    # sudo ddccontrol dev:/dev/i2c-4 -r 0x10 -w 100 1>&2 > /dev/null
    sudo ddcutil --noverify --bus 4 --sleep-multiplier 0.1 setvcp 10 100
    sudo ddcutil --noverify --bus 6 --sleep-multiplier 0.1 setvcp 10 100
  else
    echo $numberbgt
    # sudo ddccontrol dev:/dev/i2c-4 -r 0x10 -w $numberbgt 1>&2 > /dev/null
    sudo ddcutil --noverify --bus 4 --sleep-multiplier 0.1 setvcp 10 $numberbgt
    sudo ddcutil --noverify --bus 6 --sleep-multiplier 0.1 setvcp 10 $numberbgt
  fi
}  

case "$1" in
  up)
    bgt=$(cat ~/.cache/brightness)
    numberbgt=`expr $bgt + 10`

    if [ "$numberbgt" -lt 0 ]; then
      echo 0 > ~/.cache/brightness
      send_notification
      ddcset 0
    elif [ "$numberbgt" -gt 100 ]; then
      echo 100 > ~/.cache/brightness
      send_notification
      ddcset 100
    else
      echo $numberbgt > ~/.cache/brightness
      send_notification
      ddcset $numberbgt
    fi
  ;;
  down)
    bgt=$(cat ~/.cache/brightness)
    numberbgt=`expr $bgt - 10`

    if [ "$numberbgt" -lt 0 ]; then
      echo 0 > ~/.cache/brightness
      send_notification
      ddcset 0
    elif [ "$numberbgt" -gt 100 ]; then
      echo 100 > ~/.cache/brightness
      send_notification
      ddcset 100
    else
      echo $numberbgt > ~/.cache/brightness
      send_notification
      ddcset $numberbgt
    fi
  ;;
esac
