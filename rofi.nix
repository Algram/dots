{ config, pkgs, lib, ... }: {
  programs.rofi = {
    enable = true;
    font = "Roboto Mono Nerd Font 13";
    location = "center";
    theme = "/etc/nixos/dotfiles/rofi/theme.rasi";
  };
}

