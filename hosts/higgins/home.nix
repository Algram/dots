{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;

  inherit (config.lib.formats.rasi) mkLiteral;
  rofi-theme = {
    configuration = {
      font = "Noto Sans Bold 10";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "";
      drun-display-format = "{name}";
      disable-history = false;
      fullscreen = true;
      hide-scrollbar = true;
      sidebar-mode = false;
    };
    "*" = {
      background = mkLiteral "#00000060";
      background-alt = mkLiteral "#00000000";
      background-bar = mkLiteral "#f2f2f215";
      foreground = mkLiteral "#f2f2f2EE";
      accent = mkLiteral "#ffffff66";
    };

    window = {
      transparency = "real";
      background-color = mkLiteral "@background";
      text-color = mkLiteral "@foreground";
      border = 0;
      border-color = mkLiteral "@border";
      border-radius = 0;
    };

    prompt = {
      enabled = true;
      padding = mkLiteral "0.30% 1% 0% -0.5%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "@foreground";
      font = "FantasqueSansMono Nerd Font 12";
    };

    entry = {
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "@foreground";
      placeholder-color = mkLiteral "@foreground";
      expand = true;
      horizontal-align = "0";
      placeholder = "Search";
      padding = mkLiteral "0.10% 0% 0% 0%";
      blink = true;
    };

    inputbar = {
      children = map mkLiteral [ "prompt" "entry" ];
      background-color = mkLiteral "@background-bar";
      text-color = mkLiteral "@foreground";
      expand = false;
      border = mkLiteral "0.1%";
      border-radius = 6;
      border-color = mkLiteral "@accent";
      margin = mkLiteral "0% 30% 0% 30%";
      padding = mkLiteral "1%";
    };

    listview = {
      background-color = mkLiteral "@background-alt";
      columns = 7;
      lines = 4;
      spacing = mkLiteral "2%";
      cycle = false;
      dynamic = true;
      layout = "vertical";
    };

    mainbox = {
      background-color = mkLiteral "@background-alt";
      border = mkLiteral "0% 0% 0% 0%";
      border-radius = mkLiteral "0% 0% 0% 0%";
      border-color = mkLiteral "@accent";
      children = map mkLiteral [ "inputbar" "listview" ];
      spacing = mkLiteral "8%";
      padding = mkLiteral "10% 8.5% 10% 8.5%";
    };

    element = {
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "@foreground";
      orientation = "vertical";
      border-radius = mkLiteral "0%";
      padding = mkLiteral "2.5% 0% 2.5% 0%";
    };

    "element-icon" = {
      size = 81;
      border = 0;
    };

    "element-text" = {
      expand = true;
      horizontal-align = "0.5";
      vertical-align = "0.5";
      margin = mkLiteral "0.5% 0.5% -0.5% 0.5%";
    };

    "element selected" = {
      background-color = mkLiteral "@background-bar";
      text-color = mkLiteral "@foreground";
      border = mkLiteral "0% 0% 0% 0%";
      border-radius = 12;
      border-color = mkLiteral "@accent";
    };
  };
in {
  imports = [
    ./sway.nix
    ./mako.nix
    ./kitty.nix
    ./makima/makima.nix
    ./volume/volume.nix
    ./denon
    # ./waybar.nix
  ];

  home.stateVersion = "21.03";
  programs.kitty.enable = true; # required for the default Hyprland config

  programs.rofi = {
    enable = true;
    font = "Roboto Mono Nerd Font 26";
    location = "center";
    # theme = rofi-theme;
    # theme = "/etc/nixos/dotfiles/rofi/theme.rasi";
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Pop-dark";
      package = pkgs.pop-gtk-theme;
    };
  };

  home.sessionVariables = {
    # Fix antialasing ?
    FREETYPE_PROPERTIES = "truetype:interpreter-version=35";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XDG_CURRENT_DESKTOP =
      "Hyprland"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_DESKTOP =
      "Hyprland"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_TYPE =
      "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };

  # home.sessionCommands = ''
  #   sleep 1 && swaymsg "workspace 1; exec flatpak run com.github.iwalton3.jellyfin-media-player; workspace back_and_forth"
  #   sleep 2 && swaymsg "workspace 2; exec firefox --new-window --kiosk https://twitch.tv; workspace back_and_forth"
  #   sleep 5 && swaymsg "workspace 4; exec firefox --new-window --kiosk https://zdf.de; workspace back_and_forth"
  # '';

  # systemd.user.startServices = false;
  # systemd.user.services.squeezelite-user-living-room = let
  #   name = "Living Room";
  #   server = "default";
  # in {
  #   Unit.Description = "squeezelite player";
  #   # Unit.After = [ "network-online.target" "sound.target" ];
  #   # Install.WantedBy = [ "graphical-session.target" ];
  #   Service = {
  #     # ExecStartPre = "/run/current-system/sw/bin/sleep 5";
  #     # ExecStart = ''${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n "${name}" -s ${server} -d all=info'';
  #     ExecStart = ''
  #       ${pkgs.squeezelite}/bin/squeezelite -n "${name}" -s ${server} -d all=info'';
  #   };
  # };

  # systemd.user.timers."start-squeezelite-user-living-room" = {
  #   Install.WantedBy = [ "timers.target" ];
  #   Timer = {
  #     OnBootSec = "30s";
  #     Unit = "squeezelite-user-living-room.service";
  #   };
  # };

  # services.spotifyd = {
  #   enable = false;
  #   settings = {
  #     global = {
  #       username = secrets.spotify.username;
  #       password = secrets.spotify.password;
  #       device_name = "Living Room";
  #       device = "hdmi:CARD=HDMI,DEV=1";
  #     };
  #   };
  # };

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

  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    systemd.variables = [ "--all" ];
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    exec-once = [
      "[workspace 5 silent] kodi"
      "hyperhdr"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      # "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      # "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK"
      "squeekboard"
      "[workspace 5 silent] sc-controller"
      # "[workspace 2 silent] firefox --new-window --kiosk https://twitch.tv"
      "[workspace 2 silent] firefox --no-remote --profile ~/.mozilla/firefox/w6b40v6w.default --kiosk https://twitch.tv"
      "[workspace 4 silent] firefox --no-remote --profile ~/.mozilla/firefox/u96o9ybc.zdf --kiosk https://zdf.de"
      "[workspace 3 silent] flatpak run rocks.shy.VacuumTube"
      # "[workspace 1 silent] uwsm app -- flatpak run com.github.iwalton3.jellyfin-media-player"
      "[workspace 1 silent] uwsm app -- flatpak run org.jellyfin.JellyfinDesktop"
      "sudo -E makima"
      # "wayvnc --output HDMI-A-1 0.0.0.0 -p 5900"
      # "uwsm app -- hyperhdr"
    ];

    # env = [
    #   "XDG_CURRENT_DESKTOP,Hyprland"
    #   "XDG_SESSION_TYPE,wayland"
    #   "XDG_SESSION_DESKTOP,Hyprland"
    # ];

    # windowrule = [
    #   "workspace 1, class:com.github.iwalton3.jellyfin-media-player"
    #   # "workspace 2, class:firefox"
    #   "workspace 3, class:VacuumTube"
    #   "workspace 5, class:Kodi"
    #   "workspace 5, class:.sc-controller-wrapped"
    #   "fullscreen, class:com.github.iwalton3.jellyfin-media-player"
    # ];

    # windowrule.jf = {
    #   "match:class" = "com.github.iwalton3.jellyfin-media-player";
    #   workspace = "1";
    # };

    # windowrule. = {
    #   "match:class" = "com.github.iwalton3.jellyfin-media-player";
    #   workspace = "1";
    # };

    # monitor = [ "HDMI-A-1, 3840x2160@59.940Hz, 0x0, 1, bitdepth, 10, cm, hdr" ];

    monitorv2 = {
      output = "HDMI-A-1";
      mode = "3840x2160@59.940Hz";
      position = "0x0";
      scale = "1";
      bitdepth = "10";
      cm = "hdr";
      supports_wide_color = true;
      supports_hdr = true;
      sdr_min_luminance = 5.0e-3;
    };

    binds = {
      workspace_back_and_forth = false;
      allow_workspace_cycles = false;
      movefocus_cycles_fullscreen = false;
    };

    misc = {
      force_default_wallpaper = "0";
      initial_workspace_tracking = "0";
      # screencopy_force_8b = true;
    };

    animation = [ "workspaces, 1, 3, default" ];

    # render = {
    #   direct_scanout = 1;
    #   cm_fs_passthrough = 1;
    # };

    bindel = [
      ",XF86AudioLowerVolume, exec, /home/${secrets.username}/.local/bin/volume down"
      ",XF86AudioRaiseVolume, exec, /home/${secrets.username}/.local/bin/volume up"
    ];

    bind = [
      "$mod, Left, workspace, e-1"
      "$mod, Right, workspace, e+1"
      "$mod, T, exec, kitty"
      "$mod, F,fullscreen"
      "$mod, p, exec, rofi -modi drun -show-icons -show drun"
      "$mod, w, killactive"
    ] ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList (i:
        let ws = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]) 9));
  };
}

#  assigns = {
#         # "2" = [{ app_id = "firefox"; }];
#         "3" = [{ class = "VacuumTube"; }];
#         "5" = [ { class = "Kodi"; } { app_id = ".sc-controller-wrapped"; } ];
#         # "4" = [{ app_id = "com.github.iwalton3.jellyfin-media-player"; }];
#         # "3: term" = [{ class = "Kitty"; }];
#         # "4: social" = [{ class = "Signal"; }];
#         # "999: media" = [ { class = ".obs-wrapped"; } { class = "discord"; } {app_id = "com.obsproject.Studio"; }];
#       };

