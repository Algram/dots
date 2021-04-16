{ config, pkgs, lib, ... }:

let wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  programs.rofi = {
    enable = true;
    font = "Roboto Mono Nerd Font 13";
    lines = 8;
    location = "center";
    theme = "/etc/nixos/dotfiles/rofi/theme.rasi";
  };
}

