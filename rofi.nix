{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  programs.rofi = {
    enable = true;
    package = unstable.rofi.override { plugins = [ unstable.rofi-emoji ]; };

    font = "Roboto Mono 13";
    lines = 8;
    location = "center";
    theme = "/etc/nixos/dotfiles/rofi/theme.rasi";
  };
}

