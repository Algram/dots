{ config, pkgs, lib, ... }:

let
  wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  environment.systemPackages = with pkgs; [
    wofi
  ];
}

