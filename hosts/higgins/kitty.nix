{ config, pkgs, lib, ... }: {
  programs.kitty = {
    enable = true;
    font.name = "Roboto Mono 64";
    settings = {
      window_padding_width = "8.0";
      wheel_scroll_multiplier = "32.0";
      touch_scroll_multiplier = "32.0";
      confirm_os_window_close = 0;
      repaint_delay = 8;
      input_delay = 0;
      sync_to_monitor = "no";
      allow_remote_control = "yes";
    };

    keybindings = {
      "ctrl+c" = "copy_and_clear_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+shift+left" = "no_op";
      "ctrl+shift+right" = "no_op";
      "ctrl+shift+home" = "no_op";
      "ctrl+shift+end" = "no_op";
    };
  };
}
