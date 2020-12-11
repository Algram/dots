{ config, pkgs, lib, ... }: {
  programs.kitty = {
    enable = true;
    font.name = "Roboto Mono 32";
    settings = {
      window_padding_width = "8.0";
      wheel_scroll_multiplier = "32.0";
      touch_scroll_multiplier = "32.0";
    };
  };
}