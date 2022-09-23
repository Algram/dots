{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    swaylock-fancy
    swayidle
    xwayland # for legacy apps
    waybar # status bar
    mako # notification daemon
    clipman
    wf-recorder
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.base = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    config = {
      modifier = "Mod4";

      startup = [
        { command = "wal --theme /etc/nixos/dotfiles/colors.json -t -n -e"; }
        { command = "code --folder-uri ~/Dropbox/notes"; }
        { command = "dropbox"; }
        { command = "ydotoold"; }
        { command = "sh /etc/nixos/dotfiles/scripts/listener.sh"; }
        # {
        #   command = "pulseeffects --gapplication-service";
        # }
        # Fixes various sway issues: https://github.com/NixOS/nixpkgs/issues/119445
        {
          command = "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
          always = true;
        }
        {
          command =
            "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK";
          always = true;
        }
      ];

      assigns = {
        "1: web" = [{ class = "Firefox"; }];
        "2: dev" = [{ class = "Code"; }];
        "3: term" = [{ class = "Kitty"; }];
        "4: social" = [{ class = "Signal"; }];
        "999: media" = [ { class = ".obs-wrapped"; } { class = "discord"; } {app_id = "com.obsproject.Studio"; }];
      };

      input = {
        # "type:pointer" = {
        #   # Disable acceleration
        #   accel_profile = "flat";

        #   # Set the dpi to speed ratio (like mouse speed settings in windows)
        #   pointer_accel = "-0.25";
        # };

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
        };
      };

      output = {
        "*" = {
          adaptive_sync = "off";
          bg = "~/wall7.jpg fill";
          max_render_time = "1";
        };

        "DP-1" = {
          mode = "2560x1440@143.912003Hz";
          pos = "1440 590";
          max_render_time = "1";
        };

        "DP-2" = {
          mode = "2560x1440@143.912003Hz";
          transform = "270";
          pos = "0 0";
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

      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+Return" = "exec kitty";
          "${modifier}+1" = "workspace 1: web";
          "${modifier}+2" = "workspace 2: dev";
          "${modifier}+3" = "workspace 3: term";
          "${modifier}+4" = "workspace 4: social";
          "${modifier}+5" = "workspace 5: misc";
          "${modifier}+6" = "workspace 6: temp";
          "${modifier}+Escape" = "workspace 999: media";
          "${modifier}+Shift+1" = "move container to workspace 1: web";
          "${modifier}+Shift+2" = "move container to workspace 2: dev";
          "${modifier}+Shift+3" = "move container to workspace 3: term";
          "${modifier}+Shift+4" = "move container to workspace 4: social";
          "${modifier}+Shift+5" = "move container to workspace 5: misc";
          "${modifier}+Shift+6" = "move container to workspace 6: temp";
          "${modifier}+Shift+Escape" = "move container to workspace 999: media";
          "XF86AudioLowerVolume" =
            "exec /etc/nixos/dotfiles/scripts/volume.sh down";
          "XF86AudioRaiseVolume" =
            "exec /etc/nixos/dotfiles/scripts/volume.sh up";
          "${modifier}+XF86AudioLowerVolume" =
            "exec /etc/nixos/dotfiles/scripts/brightness.sh down";
          "${modifier}+XF86AudioRaiseVolume" =
            "exec /etc/nixos/dotfiles/scripts/brightness.sh up";
          "XF86AudioMute" = "exec /etc/nixos/dotfiles/scripts/volume.sh mute";
          "${modifier}+w" = "kill";
          "${modifier}+l" = "exec swaylock-fancy -e -t ''";

          # Launchers
          "${modifier}+space" =
            "exec /etc/nixos/dotfiles/scripts/launcher.sh default";
          "Mod1+space" = "exec /etc/nixos/dotfiles/scripts/launcher.sh gopass";
          "Ctrl+space" =
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
          "${modifier}+n" = "scratchpad show";
          "${modifier}+Shift+n" = "move scratchpad";

          # Layout modifiers
          "${modifier}+m" = "layout toggle tabbed split";
          "${modifier}+c" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+Shift+f" = "floating toggle";
          # "${modifier}+Shift+s" = "sticky toggle";
        };

      bars = [{ command = "waybar"; }];
    };

    extraConfig = ''
      include "~/.cache/wal/colors-sway"

      client.unfocused $color8 $color8 $foreground $color0 $color8
      client.focused_inactive $color8 $color8 $foreground $color0 $color8
      client.focused $color0 $background $foreground $color0 $color15
      title_align center
      titlebar_border_thickness 0
      titlebar_padding 8
      default_border pixel 0

      set $gnome-schema org.gnome.desktop.interface

      exec_always {
          gsettings set $gnome-schema gtk-theme 'Materia-dark-compact'
          gsettings set $gnome-schema icon-theme 'Papirus-Dark'
          gsettings set $gnome-schema cursor-theme 'Adwaita'
      }

      for_window [title="Notes"] move scratchpad, urgent disable

      for_window [title=".*\(Private Browsing\).*"] move to workspace 999: media
      for_window [title="Wine System Tray"] kill

      for_window [title="Picture-in-Picture"] floating enable, move absolute position 0 942, sticky enable, move to workspace 999: media
      for_window [title="Windowed Projector (Preview)"] fullscreen enable, move to workspace screenshare

      workspace 1: web output DP-1
      workspace 2: dev output DP-1
      workspace 3: term output DP-1
      workspace 4: social output DP-1
      workspace 5: misc output DP-1
      workspace 6: temp output DP-1
      workspace 999: media output DP-2
      workspace screenshare output DP-1
    '';
  };
}
