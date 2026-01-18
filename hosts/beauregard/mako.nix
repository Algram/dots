{ config, pkgs, lib, ... }:

let wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  services.mako = {
    enable = true;

    settings = {
      default-timeout = 3000;
      max-icon-size = 14;
      icons = true;
      layer = "overlay";
      font = "Roboto Mono 16px";
      anchor = "top-center";
      border-radius = 8;
      border-size = 0;
      margin = "12";
      padding = "12";
      width = 360;
      background-color = wal.colors.color0;
      text-color = wal.special.foreground;
      progress-color = wal.colors.color8;
      border-color = wal.colors.color8;
    };
  };
}

