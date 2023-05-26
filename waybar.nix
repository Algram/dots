{ config, pkgs, lib, ... }:

let wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  programs.waybar = {
    enable = true;
    # TODO check what this does
    systemd.enable = false;

    settings = [{
      layer = "top";
      position = "top";
      output = [ "DP-1" "HDMI-A-1" ];
      height = 38;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" "custom/recorder" ];
      modules-right = [ "custom/vpn" "custom/radon" "custom/co2" "custom/battery-mouse" "custom/power" ];
      modules = {
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
          persistant_workspaces = {
            "1: web" = [ ];
            "2: dev" = [ ];
            "3: term" = [ ];
            "4: social" = [ ];
            "5: misc" = [ ];
          };
        };

        "sway/mode" = { format = ''<span style="italic">{}</span>''; };

        "clock" = {
          interval = 30;
          format = " {:%d.%m.%Y |  %H:%M}";
        };

        "custom/battery-mouse" = {
          format = " {}";
          interval = 120;
          exec = "/etc/nixos/dotfiles/scripts/battery.sh";
        };

        "custom/co2" = {
          format = "煮 {} |";
          interval = 60;
          exec = "/etc/nixos/dotfiles/scripts/co2.sh";
        };

        "custom/radon" = {
          format = " {} |";
          interval = 60;
          exec = "/etc/nixos/dotfiles/scripts/radon.sh";
        };

        "custom/power" = {
          format = "| ";
          interval = 120;
          on-click =
            "swaynag -t warning -m 'Power Menu Options' -b 'logout' 'swaymsg exit' -b 'suspend' 'swaymsg exec systemctl suspend' -b 'shutdown' 'systemctl shutdown' -b 'windows' 'systemctl reboot --boot-loader-entry=auto-windows'";
        };

        "custom/vpn" = {
          format = " VPN | ";
          exec = "echo '{\"class\": \"connected\"}'";
          exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
          return-type = "json";
          interval = 5;
        };

        "custom/recorder" = {
          format = "";
          exec = "echo '{\"class\": \"recording\"}'";
          exec-if = "pgrep wf-recorder";
          return-type = "json";
          interval = 5;
        };
      };
    }];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Roboto Mono", Helvetica, Arial, sans-serif;
        font-size: 15px;
        min-height: 0;
        margin: 2px;
        font-weight: normal;
      }

      button {
        padding: 0;
        color: ${wal.special.foreground};
      }

      window#waybar {
        background: rgba(26, 26, 26, 0.7);
        background-color: ${wal.special.background};
        color: ${wal.special.foreground};
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      window#waybar button#sway-workspace-screenshare {
        background-color: ${wal.colors.color6};
        color: ${wal.special.background};
      }

      #workspaces button {
        padding: 0 8px 0 0;
        border-radius: 4px;
        background-color: transparent;
        color: ${wal.special.foreground};
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.3);
      }

      #workspaces button.focused {
        background-color: ${wal.colors.color0};
      }

      #workspaces button.urgent {
        background-color: ${wal.colors.color9};
      }

      #custom-power {
        min-width: 42px;
      }

      #custom-co2 {
        font-size: 15px;
      }
    '';
  };
}
