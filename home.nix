{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    (import "${
        builtins.fetchTarball
        "https://github.com/nix-community/home-manager/archive/master.tar.gz"
      }/nixos")
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${secrets.username} = { pkgs, ... }: {
    imports = [
      ./sway.nix
      ./mako.nix
      ./waybar.nix
      ./kitty.nix
      ./rofi.nix
      ./vscode.nix
    ];

    home.stateVersion = "21.03";

    home.sessionVariables = {
      # Fix antialasing ?
      FREETYPE_PROPERTIES = "truetype:interpreter-version=35";
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_CURRENT_DESKTOP =
        "sway"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
      XDG_SESSION_TYPE =
        "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
    };

    fonts.fontconfig.enable = true;

    gtk = {
      enable = true;
      iconTheme = {
        name = "Numix-Circle";
        package = pkgs.numix-icon-theme-circle;
      };
      theme = {
        name = "Materia-light-compact";
        package = pkgs.materia-theme;
      };
    };

    programs.firefox = {
      enable = true;
      # Until https://github.com/nix-community/home-manager/issues/1641 is fixed
      package = pkgs.firefox-wayland;

      profiles.default = {
        path = "1utyytkx.default";

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
    };

    services.gammastep = {
      enable = true;
      # Berlin coordinates
      latitude = "52.5200";
      longitude = "13.405";
      temperature = { night = 3000; };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

