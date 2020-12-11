{ config, pkgs, lib, ... }:

# TODO

let
  wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  programs.waybar = {
    enable = false;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "HDMI-A-1"
        ];
        modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
        modules-center = [ "sway/window" "custom/hello-from-waybar" ];
        modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];
        modules = {
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          "custom/hello-from-waybar" = {
            format = "hello {}";
            max-length = 40;
            interval = "once";
            exec = pkgs.writeShellScript "hello-from-waybar" ''
              echo "from within waybar"
            '';
          };
        };
      }
    ];
  };
}

