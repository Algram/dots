{ config, pkgs, lib, ... }:

let
  wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  programs.mako = {
    enable = true;

    layer = "overlay";
    icons = true;
    maxIconSize = 14;
    font = "Roboto Mono 16px";
    defaultTimeout = 3000;
    anchor = "top-center";

    borderRadius = 8;
    borderSize = 0;
    margin = "12";
    padding = "12";
    width = 360;

    backgroundColor = wal.colors.color0;
    textColor = wal.special.foreground;
    progressColor = wal.colors.color8;
    borderColor = wal.colors.color8;
  };
}

