{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ./sway.nix
    # ./waybar.nix
  ];


  home.stateVersion = "21.03";
  programs.kitty.enable = true; # required for the default Hyprland config


  programs.rofi = {
    enable = true;
    font = "Roboto Mono Nerd Font 13";
    location = "center";
    # theme = "/etc/nixos/dotfiles/rofi/theme.rasi";
  };

  #     systemd.user.startServices = true;
  # systemd.user.services.squeezelite-user =
  #   let name = "living-room";
  #       server = "default";
  #   in {
  #     Unit.Description = "squeezelite player";
  #     Unit.After = [ "network-online.target" "sound.target" ];
  #     Install.WantedBy = [ "graphical-session.target" ];
  #     Service = {
  #       ExecStartPre="/run/current-system/sw/bin/sleep 5";
  #       ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n ${name} -s ${server} -d all=info";
  #     };
  #   };



  # wayland.windowManager.hyprland.enable = true; # enable Hyprland



  # wayland.windowManager.hyprland.settings = {
  #     "$mod" = "SUPER";
  #     exec-once = [
  #         "kodi"
  #         "hyperhdr --pipewire"
  #         "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  #         # "uwsm app -- hyperhdr"
  #     ];

  #     windowrule = [
  #       "fullscreen,Kodi"
  #     ];

  #     windowrulev2 = [
  #       "fullscreen,class:^Kodi\d+$"
  #     ];

  #     monitor = [
  #       # "HDMI-A-1, 3840x2160@30.00Hz, 0x0, 1"
  #       "DP-2, 3840x2160@60.00Hz, 0x0, 1"
  #       # "DP-2, 1920x1080@120.00Hz, 0x0, 1"
  #     ];

  #     bind =
  #       [
  #         "$mod, T, exec, kitty"
  #         "$mod, F,fullscreen"
  #         "$mod, B,exec, firefox"
  #         "$mod, P, exec, pavucontrol"
  #         "$mod, R, exec, rofi -show drun -no-show-match -no-sort -show-icons -kb-cancel 'Super+space,Escape'"
  #         ", Print, exec, grimblast copy area"
  #       ]
  #       ++ (
  #         # workspaces
  #         # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
  #         builtins.concatLists (builtins.genList (i:
  #             let ws = i + 1;
  #             in [
  #               "$mod, code:1${toString i}, workspace, ${toString ws}"
  #               "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
  #             ]
  #           )
  #           9)
  #       );
  #   };


}
