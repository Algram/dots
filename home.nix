{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
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
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Materia-dark-compact";
        package = pkgs.materia-theme;
      };
    };

    services.kdeconnect.enable = false;
    services.nextcloud-client.enable = false;

    programs.firefox = {
      enable = true;
      # Until https://github.com/nix-community/home-manager/issues/1641 is fixed
      package = pkgs.firefox-wayland;

      profiles.default = {
        path = "1utyytkx.default";
      };
    };


    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-studio-plugins.wlrobs ];
      # plugins = with pkgs; [ obs-studio-plugins.wlrobs (callPackage /home/raphael/Downloads/nixpkgs/pkgs/applications/video/obs-studio/plugins/obs-hyperion/default.nix { inherit (qt5) qtbase; }) ];
      # plugins = with pkgs; [ obs-studio-plugins.wlrobs obs-studio-plugins.obs-hyperion ];
    };

    services.gammastep = {
      enable = false;
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

