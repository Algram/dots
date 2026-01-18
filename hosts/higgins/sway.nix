{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  home.packages = with pkgs; [
    swaylock-fancy
    swayidle
    xwayland # for legacy apps
    # waybar # status bar
    mako # notification daemon
    clipman
    # wf-recorder
  ];

  # systemd.user.services.jellyfin = {
  #   Unit = {
  #     Description = "Jellyfin Media Player (Flatpak)";
  #     After = [ "graphical-session.target" ];
  #     PartOf = [ "graphical-session.target" ];
  #   };

  #   Service = {
  #     ExecStart =
  #       "${pkgs.flatpak}/bin/flatpak run com.github.iwalton3.jellyfin-media-player";
  #     Restart = "on-failure";
  #   };

  #   Install = { WantedBy = [ "default.target" ]; };
  # };

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    systemd.enable = true;
    wrapperFeatures.base = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    systemd.variables = [ "--all" ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      export WLR_RENDERER=vulkan
    '';
    config = {
      modifier = "Mod4";
      floating.modifier = "Mod4";

      defaultWorkspace = "1";

      startup = [
        # { command = "wal --theme /etc/nixos/dotfiles/colors.json -t -n -e"; }
        # # { command = "code --folder-uri ~/Dropbox/notes"; }
        { command = "squeekboard"; }
        {
          command = "sc-controller";
        }
        # {
        #   command = ''
        #     swaymsg "workspace 1; exec flatpak run com.github.iwalton3.jellyfin-media-player; workspace back_and_forth"
        #   '';
        # }
        # { command = "flatpak run com.github.iwalton3.jellyfin-media-player"; }
        {
          command = ''
            swaymsg "workspace 2; exec firefox --new-window --kiosk https://twitch.tv; workspace back_and_forth"
          '';
        }
        { command = "exec flatpak run rocks.shy.VacuumTube"; }
        { command = "exec sudo -E makima"; }
        {
          command = "hyperhdr --pipewire";
        }
        # {
        #   command = ''
        #     swaymsg "exec swaymsg 'workspace 2; exec firefox --new-window --kiosk https://twitch.tv'"'';
        # }
        # {
        #   command = ''
        #     sleep 2 && swaymsg "workspace 2; exec firefox --new-window --kiosk https://twitch.tv; workspace back_and_forth"
        #   '';
        # }

        {
          command = ''
            sleep 4 && swaymsg "workspace 4; exec firefox --new-window --kiosk https://zdf.de; workspace back_and_forth"
          '';
        }
        { command = "kodi"; }
        {
          command = "wayvnc --output HDMI-A-1 0.0.0.0 -p 5900";
        }
        # { command = "systemctl --user --type=service"; }
        # { command = "keepassxc"; }
        # { command = "ydotoold"; }
        # { command = "xrandr --output DP-1 --primary"; }
        # { command = "sh /etc/nixos/dotfiles/scripts/listener.sh"; }
        # { command = "exec wl-paste -t text --watch clipman store"; }
        # {
        #   command = "pulseeffects --gapplication-service";
        # }
        # {
        #   command = "exec sleep 5; workspace 1";
        # }
        # Fixes various sway issues: https://github.com/NixOS/nixpkgs/issues/119445
        # {
        #   command =
        #     "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
        #   always = true;
        # }
        # {
        #   command =
        #     "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK";
        #   always = true;
        # }
      ];

      assigns = {
        # "2" = [{ app_id = "firefox"; }];
        "3" = [{ class = "VacuumTube"; }];
        "5" = [ { class = "Kodi"; } { app_id = ".sc-controller-wrapped"; } ];
        # "4" = [{ app_id = "com.github.iwalton3.jellyfin-media-player"; }];
        # "3: term" = [{ class = "Kitty"; }];
        # "4: social" = [{ class = "Signal"; }];
        # "999: media" = [ { class = ".obs-wrapped"; } { class = "discord"; } {app_id = "com.obsproject.Studio"; }];
      };

      input = {
        "type:pointer" = {
          # Disable acceleration
          accel_profile = "flat";

          # Set the dpi to speed ratio (like mouse speed settings in windows)
          pointer_accel = "1";
        };

        "5426:123:Razer_Razer_Viper_Ultimate_Dongle" = {
          # Disable acceleration
          accel_profile = "flat";

          # Set the dpi to speed ratio (like mouse speed settings in windows)
          pointer_accel = "-0.25";
        };

        "5426:122:Razer_Razer_Viper_Ultimate" = {
          # Disable acceleration
          accel_profile = "flat";

          # Set the dpi to speed ratio (like mouse speed settings in windows)
          pointer_accel = "-0.25";
        };

        "1133:16461:Logitech_K400_Plus" = {
          accel_profile = "adaptive";

          # Set the dpi to speed ratio (like mouse speed settings in windows)
          pointer_accel = "1";

          natural_scroll = "enabled";
        };
      };

      output = {
        # "*" = {
        #   adaptive_sync = "off";
        #   # bg = "~/wall7.jpg fill";
        #   max_render_time = "1";
        # };
        # "HDMI-A-4" = {
        #   # scale = "1";
        #   # mode = "3840x2160@120.000Hz";
        #   mode = "3840x2160@59.940Hz";
        #   scale = "2";
        #   # mode = "1920x1080@60.000Hz";
        #   # pos = "1440 590";
        #   # max_render_time = "1";
        # };
        "HDMI-A-1" = {
          # scale = "1";
          # mode = "3840x2160@120.000Hz";
          # swaymsg "output DP-2 mode --custom 1920x800@59.997Hz"
          # mode = "3840x2160@59.940Hz";
          mode = "3840x2160@59.940Hz";
          scale = "1";
          render_bit_depth = "10";
          hdr = "off";
          # mode = "1920x1080@60.000Hz";
          # pos = "1440 590";
          # max_render_time = "1";
        };
      };

      focus = { followMouse = false; };

      gaps = {
        inner = 12;
        smartGaps = true;
        smartBorders = "on";
      };

      window = { hideEdgeBorders = "smart"; };

      fonts = {
        names = [ "Roboto" ];
        style = "Regular";
      };

      workspaceAutoBackAndForth = true;

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        # let modifier = "Mod4";
      in lib.mkOptionDefault {
        "${modifier}+Return" = "exec kitty";
        "${modifier}+t" = "exec kitty";
        # "${modifier}+b" = "exec kitty";
        "${modifier}+1" = "workspace 1";
        "${modifier}+2" = "workspace 2";
        "${modifier}+3" = "workspace 3";
        "${modifier}+4" = "workspace 4";
        "${modifier}+5" = "workspace 5";
        "${modifier}+6" = "workspace 6";
        # "${modifier}+Escape" = "workspace 999: media";
        "${modifier}+Shift+1" = "move container to workspace 1: web";
        "${modifier}+Shift+2" = "move container to workspace 2: dev";
        "${modifier}+Shift+3" = "move container to workspace 3: term";
        "${modifier}+Shift+4" = "move container to workspace 4: social";
        "${modifier}+Shift+5" = "move container to workspace 5: misc";
        "${modifier}+Shift+6" = "move container to workspace 6: temp";
        # "${modifier}+Shift+Escape" = "move container to workspace 999: media";
        "XF86AudioLowerVolume" =
          "exec /home/${secrets.username}/.local/bin/volume down";
        "XF86AudioRaiseVolume" =
          "exec /home/${secrets.username}/.local/bin/volume up";
        # "XF86AudioMute" = "exec /home/${secrets.username}/volume.sh mute";
        "${modifier}+w" = "kill";
        "${modifier}+l" = "exec swaylock-fancy -e -t ''";

        # Launchers
        "${modifier}+p" = "exec rofi -modi drun -show-icons -show drun";
        "${modifier}+g" = "exec /etc/nixos/dotfiles/scripts/launcher.sh gopass";
        "${modifier}+b" =
          "exec /etc/nixos/dotfiles/scripts/launcher.sh clipboard";
        "Ctrl+Shift+space" = "exec clipman clear --all";

        # Umlauts
        "${modifier}+a" = ''exec /etc/nixos/dotfiles/scripts/key.sh "a" "ä"'';
        "${modifier}+Shift+a" =
          ''exec /etc/nixos/dotfiles/scripts/key.sh "a" "Ä"'';
        "${modifier}+o" = ''exec /etc/nixos/dotfiles/scripts/key.sh "o" "ö"'';
        "${modifier}+Shift+o" =
          ''exec /etc/nixos/dotfiles/scripts/key.sh "o" "Ö"'';
        "${modifier}+u" = ''exec /etc/nixos/dotfiles/scripts/key.sh "u" "ü"'';
        "${modifier}+Shift+u" =
          ''exec /etc/nixos/dotfiles/scripts/key.sh "u" "Ü"'';
        "${modifier}+s" = ''exec /etc/nixos/dotfiles/scripts/key.sh "s" "ß"'';

        # Screenshots
        "${modifier}+Shift+i" =
          "exec /etc/nixos/dotfiles/scripts/screen.sh area";
        "${modifier}+Shift+d" =
          "exec /etc/nixos/dotfiles/scripts/screen.sh annotate";
        "${modifier}+Shift+w" =
          "exec /etc/nixos/dotfiles/scripts/screen.sh window";
        "${modifier}+Shift+p" =
          "exec /etc/nixos/dotfiles/scripts/screen.sh color";
        "${modifier}+Shift+v" =
          "exec /etc/nixos/dotfiles/scripts/screen.sh record_area";

        # Screenshots
        "${modifier}+Shift+s" =
          "exec /etc/nixos/dotfiles/scripts/screenshare.sh";

        # Scratchpad
        "${modifier}+n" = "[class=obsidian] scratchpad show";
        "${modifier}+Shift+n" = "scratchpad show";
        "${modifier}+k" = "[app_id=org.keepassxc.KeePassXC] scratchpad show";
        # "${modifier}+Shift+n" = "move scratchpad";

        # Layout modifiers
        "${modifier}+m" = "layout toggle tabbed split";
        "${modifier}+c" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+f" = "floating toggle";
        # "${modifier}+Shift+s" = "sticky toggle";
        "${modifier}+Left" = "workspace prev_on_output";
        "${modifier}+Right" = "workspace next_on_output";

      };

      bars = [{ command = "waybar"; }];
    };

    extraConfig = ''
      include "~/.cache/wal/colors-sway"

      # client.unfocused $color8 $color8 $foreground $color0 $color8
      # client.focused_inactive $color8 $color8 $foreground $color0 $color8
      # client.focused $color0 $background $foreground $color0 $color15
      title_align center
      titlebar_border_thickness 0
      titlebar_padding 8
      default_border pixel 0

      set $gnome-schema org.gnome.desktop.interface

      exec_always {
          gsettings set $gnome-schema gtk-theme 'Pop-dark'
          gsettings set $gnome-schema icon-theme 'Papirus-Dark'
          gsettings set $gnome-schema cursor-theme 'Adwaita'
          gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
          # gsettings set sm.puri.Squeekboard layout-shape-changes-to-fit-panel false
      }

      # for_window [title="Notes"] move scratchpad, urgent disable
      # for_window [class="obsidian"] move scratchpad, urgent disable
      # for_window [app_id="org.keepassxc.KeePassXC"] move scratchpad, urgent disable

      # for_window [title=".*\(Private Browsing\).*"] move to workspace 999: media
      # for_window [title="Wine System Tray"] kill

      # for_window [title="Picture-in-Picture"] floating enable, move absolute position 0 942, sticky enable, move to workspace 999: media
      # for_window [class="Kodi"] fullscreen enable

      workspace 1 output HDMI-A-1
      workspace 2 output HDMI-A-1
      workspace 3 output HDMI-A-1
      workspace 4 output HDMI-A-1
      workspace 5 output HDMI-A-1
      # workspace 3: term output DP-1
      # workspace 4: social output DP-1
      # workspace 5: misc output DP-1
      # workspace 6: temp output DP-1
      # workspace 999: media output DP-2
      # workspace screenshare output DP-1
    '';
  };
}
