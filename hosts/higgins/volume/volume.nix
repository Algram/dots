{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets.nix;
  cfgDir = ./.;
in {
  home.file.".local/bin/volume" = {
    text = ''
      #!/usr/bin/env bash

      # Utility for volume control and a notification popup with mako.

      function send_notification {
        volume="$1"

        # Send the volume indicator notification with mako
        # /home/${secrets.username}/notify-send.sh -t 1000 --replace-file=/home/${secrets.username}/.temp/sound --hint=int:value:"$volume" "$volume"
      }

      case "$1" in
        up)
          INT_VOL=$(/home/${secrets.username}/.local/bin/denon/increase-volume)
          send_notification "$INT_VOL"
        ;;
        down)
          INT_VOL=$(/home/${secrets.username}/.local/bin/denon/decrease-volume)
          send_notification "$INT_VOL"
        ;;
      esac
    '';
    executable = true;
  };
}

