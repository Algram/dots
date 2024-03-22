#!/usr/bin/env bash

KEEPASSXC_PASS_PATH="Web"
KEEPASSXC_DATABASE_PATH=$(readlink -f ~/Nextcloud/Passwords/Passwords.kdbx)
CLIP_TIMEOUT="45"

passCommand() {
  while getopts "a:e:" opt; do
    case "$opt" in
    a) ARGS="$OPTARG" ;;
    e) ELEMENT="$OPTARG" ;;
    *) echo "ERROR: incorrect flag!" ;;
    esac
  done
  : "${ARGS=}"
  COMMAND="
    keepassxc-cli clip ${ARGS} ${KEEPASSXC_DATABASE_PATH} ${secret} ${CLIP_TIMEOUT} &
    notify-send --icon=dialog-information \"${ELEMENT} is copied to clipboard!\"
  "
  eval ${COMMAND}
}

# secret=$(pass "${KEEPASSXC_PASS_PATH}" | keepassxc-cli ls -R -f "${KEEPASSXC_DATABASE_PATH}" | sed -e '/\/$/d' -e '/Recycle Bin/d' | rofi -kb-custom-1 "Alt+Return" -kb-custom-2 "Ctrl+Alt+Return" -dmenu -p "Secret")
secret=$(keepassxc-cli ls -R -f ~/Nextcloud/Passwords/Passwords.kdbx /Web | sed -e '/\/$/d' -e '/Recycle Bin/d' | rofi -kb-custom-1 "Alt+Return" -kb-custom-2 "Ctrl+Alt+Return" -dmenu -p "Secret")
EXIT_CODE="$?"
if [ "${EXIT_CODE}" == "0" ]; then
  passCommand -e "Password"
elif [ "${EXIT_CODE}" == "10" ]; then
  passCommand -e "OTP" -a "-t"
elif [ "${EXIT_CODE}" == "11" ]; then
  passCommand -e "Username" -a "-a username"
fi