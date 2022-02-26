#!/bin/sh

# ALPHA

case "$1" in
  start)
    $0 stop 
    pactl load-module module-simple-protocol-tcp rate=44100 format=s16le channels=2 source=alsa_output.pci-0000_0c_00.4.analog-stereo.monitor record=true port=8001
    ;;
  stop)
    pactl unload-module `pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g'`
    ;;
  *)
    echo "Usage: $0 start|stop" >&2
    ;;
esac