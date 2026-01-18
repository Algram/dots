{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets.nix;
  cfgDir = ./.;
in {
  home.file.".local/bin/denon/increase-volume" = {
    text = ''
      #!/usr/bin/env bash

      # CONFIG
      HA_URL="${secrets.homeAssistant.url}"
      TOKEN="${secrets.homeAssistant.token}"
      SCRIPT_ENTITY_ID="${secrets.homeAssistant.scriptVolumeUpEntityId}"

      # Call the Home Assistant script
      curl -s -X POST "$HA_URL/api/services/script/turn_on" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"entity_id\": \"$SCRIPT_ENTITY_ID\"}" > /dev/null

      # #!/usr/bin/env bash

      # # CONFIG
      # HA_URL="${secrets.homeAssistant.url}"
      # TOKEN="${secrets.homeAssistant.token}"
      # ENTITY_ID=""
      # STEP=0.02  # Increase volume by fixed 0.02

      # # Fetch current volume
      # CURRENT_VOL=$(curl -s -X GET "$HA_URL/api/states/$ENTITY_ID" \
      #   -H "Authorization: Bearer $TOKEN" \
      #   -H "Content-Type: application/json" | jq '.attributes.volume_level')

      # # Compute new volume by adding fixed STEP
      # NEW_VOL=$(echo "$CURRENT_VOL + $STEP" | bc -l)
      # # Prepend zero if result starts with '.'
      # if [[ $NEW_VOL == .* ]]; then
      #   NEW_VOL="0$NEW_VOL"
      # fi

      # # Clamp max volume to 1.0
      # if (( $(echo "$NEW_VOL > 1.0" | bc -l) )); then
      #   NEW_VOL=1.0
      # fi

      # curl -s -X POST "$HA_URL/api/services/media_player/volume_set" \
      #   -H "Authorization: Bearer $TOKEN" \
      #   -H "Content-Type: application/json" \
      #   -d "{\"entity_id\": \"$ENTITY_ID\", \"volume_level\": $NEW_VOL}" > /dev/null


      # INT_VOL=$(echo "$NEW_VOL * 100" | bc -l | cut -d. -f1)
      # # Output final volume as integer
      # echo "$INT_VOL"
          '';
    executable = true;
  };
}
