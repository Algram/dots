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
    package = pkgs.sway;
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
        { command = "pulseeffects --gapplication-service"; }
        # Maybe fixes fonts and or dbus openrazer
        { command = "dbus-update-activation-environment $DISPLAY"; always = true; }
      ];

      assigns = {
        "1: web" = [{ class = "Firefox"; }];
        "2: dev" = [{ class = "Code"; }];
        "3: term" = [{ class = "Kitty"; }];
        "4: social" = [{ class = "Signal"; }];
        "999: media" = [{ class = "obs"; } { class = "discord"; } { title = "Picture-in-Picture"; }];
      };

      input = {
        "type:pointer" = {
          # Disable acceleration
          accel_profile = "flat";

          # Set the dpi to speed ratio (like mouse speed settings in windows)
          pointer_accel = "-0.25";
        };
      };

      output = {
        "*" = {
          bg = "~/wall4.jpg fill";
        };

        "DP-1" = {
          mode = "2560x1440@143.912003Hz";
          pos = "1440 590";
        };

        "DP-2" = {
          mode = "2560x1440@143.912003Hz";
          transform = "270";
          pos = "0 0";
        };
      };

      focus = {
        followMouse = false;
      };

      gaps = {
        inner = 12;
        smartGaps = true;
        smartBorders = "on";
      };

      window = {
        hideEdgeBorders = "smart";
      };

      fonts = [ "Roboto Mono 11" ];

      workspaceAutoBackAndForth = true;

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${modifier}+Return" = "exec kitty";
        "${modifier}+1" = "workspace 1: web";
        "${modifier}+2" = "workspace 2: dev";
        "${modifier}+3" = "workspace 3: term";
        "${modifier}+4" = "workspace 4: social";
        "${modifier}+5" = "workspace 5: misc";
        "${modifier}+6" = "workspace 6: temp";
        "${modifier}+Escape" = ''workspace 999: media'';
        "${modifier}+Shift+1" = "move container to workspace 1: web";
        "${modifier}+Shift+2" = "move container to workspace 2: dev";
        "${modifier}+Shift+3" = "move container to workspace 3: term";
        "${modifier}+Shift+4" = "move container to workspace 4: social";
        "${modifier}+Shift+5" = "move container to workspace 5: misc";
        "${modifier}+Shift+6" = "move container to workspace 6: temp";
        "${modifier}+Shift+Escape" = "move container to workspace 999: media";
        "XF86AudioLowerVolume" = "exec /etc/nixos/dotfiles/scripts/volume.sh down";
        "XF86AudioRaiseVolume" = "exec /etc/nixos/dotfiles/scripts/volume.sh up";
        "${modifier}+XF86AudioLowerVolume" = "exec /etc/nixos/dotfiles/scripts/brightness.sh down";
        "${modifier}+XF86AudioRaiseVolume" = "exec /etc/nixos/dotfiles/scripts/brightness.sh up";
        "XF86AudioMute" = "exec /etc/nixos/dotfiles/scripts/volume.sh mute";
        "${modifier}+w" = "kill";
        "${modifier}+l" = "exec swaylock-fancy -e -t ''";

        # Launchers
        "${modifier}+space" = "exec /etc/nixos/dotfiles/scripts/launcher.sh default";
        "Mod1+space" = "exec /etc/nixos/dotfiles/scripts/launcher.sh gopass";
        "Ctrl+space" = "exec /etc/nixos/dotfiles/scripts/launcher.sh clipboard";
        "Ctrl+Shift+space" = "exec clipman clear --all";
        "Shift+space" = "exec /etc/nixos/dotfiles/scripts/launcher.sh emoji";

        # Umlauts
        "${modifier}+a" = ''exec /etc/nixos/dotfiles/scripts/key.sh "a" "ä"'';
        "${modifier}+Shift+a" = ''exec /etc/nixos/dotfiles/scripts/key.sh "a" "Ä"'';
        "${modifier}+o" = ''exec /etc/nixos/dotfiles/scripts/key.sh "o" "ö"'';
        "${modifier}+Shift+o" = ''exec /etc/nixos/dotfiles/scripts/key.sh "o" "Ö"'';
        "${modifier}+u" = ''exec /etc/nixos/dotfiles/scripts/key.sh "u" "ü"'';
        "${modifier}+Shift+u" = ''exec /etc/nixos/dotfiles/scripts/key.sh "u" "Ü"'';
        "${modifier}+s" = ''exec /etc/nixos/dotfiles/scripts/key.sh "s" "ß"'';

        # Screenshots
        "${modifier}+Shift+i" = "exec /etc/nixos/dotfiles/scripts/screen.sh area";
        "${modifier}+Shift+w" = "exec /etc/nixos/dotfiles/scripts/screen.sh window";
        "${modifier}+Shift+p" = "exec /etc/nixos/dotfiles/scripts/screen.sh color";
        "${modifier}+Shift+v" = "exec /etc/nixos/dotfiles/scripts/screen.sh record_area";

        # Scratchpad
        "${modifier}+n" = "scratchpad show";
        "${modifier}+Shift+n" = "move scratchpad";

        # Layout modifiers
        "${modifier}+m" = "layout toggle tabbed split";
        "${modifier}+c" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+f" = "floating toggle";
        "${modifier}+Shift+s" = "sticky toggle";
      };

      bars = [
        {
          command = "waybar";
        }
      ];
    };

    extraConfig = ''
      include "~/.cache/wal/colors-sway"

      client.unfocused $color8 $color8 $foreground $color0 $color8
      client.focused_inactive $color8 $color8 $foreground $color0 $color8
      client.focused $color0 $background $foreground $color0 $color15
      title_align center
      titlebar_border_thickness 0
      titlebar_padding 8

      set $gnome-schema org.gnome.desktop.interface

      exec_always {
          gsettings set $gnome-schema gtk-theme 'Materia-light-compact'
          gsettings set $gnome-schema icon-theme 'Numix-Circle'
          gsettings set $gnome-schema cursor-theme 'Adwaita'
      }

      for_window [title="Notes"] move scratchpad, urgent disable

      for_window [title=".*\(Private Browsing\).*"] move to workspace 999: media

      for_window [title="Microsoft Teams Notification"] move absolute position 1130 px 48 px

      for_window [title="Wine System Tray"] kill

      for_window [title="Picture-in-Picture"] floating enable, move absolute position 1690 942, sticky enable

      workspace 1: web output DP-1
      workspace 2: dev output DP-1
      workspace 3: term output DP-1
      workspace 4: social output DP-1
      workspace 5: misc output DP-1
      workspace 6: temp output DP-1
      workspace 999: media output DP-2
    '';
  };
}
