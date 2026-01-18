{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  spotifydBathroomWatchdog =
    pkgs.writeShellScriptBin "spotifyd-bathroom-watchdog" ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Check logs for MAC mismatch in the last minute
      THRESHOLD=1
      WINDOW=60  # seconds
      SERVICE="spotifyd-bathroom.service"

      count=$(journalctl --user -u "$SERVICE" --since "60 seconds ago" | grep -c 'Login error.*MAC mismatch' || true)

      if [ "$count" -gt "$THRESHOLD" ]; then
        echo "Restarting $SERVICE due to MAC mismatch errors"
        systemctl --user restart "$SERVICE"
      fi
    '';
in {

}
