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

  home.stateVersion = "21.03";

  systemd.user.startServices = true;
  # systemd.user.services.squeezelite-user-office = let
  #   name = "Office";
  #   server = "default";
  # in {
  #   Unit.Description = "squeezelite player";
  #   # Unit.After = [ "network-online.target" "sound.target" ];
  #   # Install.WantedBy = [ "graphical-session.target" ];
  #   Service = {
  #     # ExecStartPre = "/run/current-system/sw/bin/sleep 5";
  #     # ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n ${name} -s ${server} -d all=info -o alsa_output.pci-0000_00_1f.3.analog-stereo -m ab:cd:ef:12:34:56";
  #     # ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n ${name} -s ${server} -d all=info -o alsa_output.pci-0000_00_1f.3.analog-stereo -m ab:cd:ef:12:34:56";
  #     ExecStart =
  #       "${pkgs.squeezelite}/bin/squeezelite -n ${name} -s ${server} -d all=info -o sysdefault:Device -m ab:cd:ef:12:34:56";
  #   };
  # };

  # systemd.user.services.squeezelite-user-bathroom = let
  #   name = "Bathroom";
  #   server = "default";
  # in {
  #   Unit.Description = "squeezelite player";
  #   # Unit.After = [ "network-online.target" "sound.target" ];
  #   # Install.WantedBy = [ "graphical-session.target" ];
  #   Service = {
  #     # ExecStartPre = "/run/current-system/sw/bin/sleep 5";
  #     # ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n ${name} -s ${server} -d all=info -o bluez_sink.88_92_CC_01_77_11.a2dp_sink -m ab:cd:ef:12:34:57";
  #     ExecStart =
  #       "${pkgs.squeezelite}/bin/squeezelite -n ${name} -s ${server} -d all=info -o default -m ab:cd:ef:12:34:57";
  #   };
  # };

  # ---

  systemd.user.services.sendspin-user-office = let
    name = "Office";
    id = "office";
    server = "default";
  in {
    Unit.Description = "sendspin player";
    Service = {
      ExecStart =
        # "${pkgs.sendspin-cli}/bin/sendspin --id ${id} --name ${name} --audio-device 5 --static-delay-ms -50";
        ''
          ${pkgs.sendspin-cli}/bin/sendspin daemon --id ${id} --name ${name} --audio-device "USB PnP Sound Device: Audio" --static-delay-ms -20 --port 8926'';
    };
  };

  systemd.user.services.sendspin-user-bathroom = let
    name = "Bathroom";
    id = "bathroom";
    server = "default";
  in {
    Unit.Description = "sendspin player";
    Service = {
      ExecStart = ''
        ${pkgs.sendspin-cli}/bin/sendspin daemon --id ${id} --name ${name} --audio-device "default" --static-delay-ms -270 --port 8928'';
    };
  };

  # ---

  systemd.user.timers."start-sendspin-user-office" = {
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnBootSec = "90s";
      Unit = "sendspin-user-office.service";
    };
  };

  systemd.user.timers."start-sendspin-user-bathroom" = {
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnBootSec = "120s";
      # OnUnitActiveSec = "1m";
      Unit = "sendspin-user-bathroom.service";
    };
  };

  systemd.user.timers."start-bluetooth" = {
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnBootSec = "80s";
      OnUnitActiveSec = "1m";
      Unit = "start-bluetooth.service";
    };
  };

  systemd.user.services."start-bluetooth" = {
    Service = {
      ExecStart = "${pkgs.bluez}/bin/bluetoothctl connect 88:92:CC:01:77:11";
    };
  };

  systemd.user.timers."start-pa" = {
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnBootSec = "60s";
      Unit = "start-pa.service";
    };
  };

  systemd.user.services."start-pa" = {
    Service = { ExecStart = "systemctl --user restart pulseaudio"; };
  };

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = secrets.spotify.username;
        password = secrets.spotify.password;
        device_name = "Office";
        device = "sysdefault:Device";
      };
    };
  };

  systemd.user.services.spotifyd-bathroom = {
    Unit = {
      Description = "spotify daemon";
      Documentation = "https://github.com/Spotifyd/spotifyd";
    };

    Install.WantedBy = [ "default.target" ];

    Service = {
      ExecStart =
        "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path /home/${secrets.username}/spotifyd-bathroom.conf";
      Restart = "always";
      RestartSec = 12;
    };
  };

  # The watchdog service
  # systemd.user.services.spotifyd-bathroom-watchdog = {
  #   Unit = {
  #     Description = "Restart spotifyd-bathroom if MAC mismatch errors occur";
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${spotifydBathroomWatchdog}/bin/spotifyd-bathroom-watchdog";
  #   };
  # };

  # # The watchdog timer
  # systemd.user.timers.spotifyd-bathroom-watchdog = {
  #   Unit = { Description = "Periodic spotifyd-bathroom log check"; };
  #   Timer = {
  #     OnBootSec = "2min";
  #     OnUnitActiveSec = "1min";
  #     Unit = "spotifyd-bathroom-watchdog.service";
  #   };
  #   Install = { WantedBy = [ "timers.target" ]; };
  # };

  # systemd services
  # systemd.user.services = {
  #   # nqptp = {
  #   #   description = "Network Precision Time Protocol for Shairport Sync";
  #   #   wantedBy = [ "multi-user.target" ];
  #   #   after = [ "network.target" ];
  #   #   serviceConfig = {
  #   #     ExecStart = "${pkgs.nqptp}/bin/nqptp";
  #   #     Restart = "always";
  #   #     RestartSec = "5s";
  #   #   };
  #   # };
  #   shairport-sync-office = {
  #     Unit = { Description = "Dining room speakers shairport-sync instance"; };
  #     Install.WantedBy = [ "multi-user.target" ];
  #     # after = [ "network.target" ];
  #     Service = {
  #       # User = "shairport";
  #       # Group = "shairport";
  #       ExecStart =
  #         "${pkgs.shairport-sync}/bin/shairport-sync -v -c /etc/office.conf";
  #       Restart = "on-failure";
  #       # RuntimeDirectory = "shairport-sync";
  #     };
  #   };

  #   shairport-sync-bathroom = {
  #     Unit = { Description = "Dining room speakers shairport-sync instance"; };
  #     Install.WantedBy = [ "multi-user.target" ];
  #     # after = [ "network.target" ];
  #     Service = {
  #       # User = "shairport";
  #       # Group = "shairport";
  #       ExecStart =
  #         "${pkgs.shairport-sync}/bin/shairport-sync -v -c /etc/bathroom.conf";
  #       Restart = "on-failure";
  #       # RuntimeDirectory = "shairport-sync";
  #     };
  #   };
  # outdoor-speakers = {
  #   description = "Outdoor speakers shairport-sync instance";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" "avahi-daemon.service" ];
  #   serviceConfig = {
  #     User = "shairport";
  #     Group = "shairport";
  #     ExecStart =
  #       "${pkgs.shairport-sync-airplay2}/bin/shairport-sync -c /etc/outdoor_speakers.conf";
  #     Restart = "on-failure";
  #     RuntimeDirectory = "shairport-sync";
  #   };
  # };
  # };

  # services.spotifyd = {
  #   enable = true;
  #   settings = {
  #     global = {
  #       username = secrets.spotify.username;
  #       password = secrets.spotify.password;
  #       device_name = "bathroom";
  #       device = "default";
  #     };
  #   };
  # };

}
