{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    ./sway.nix
    ./mako.nix
    ./waybar.nix
    ./kitty.nix
    ./rofi.nix
    ./vscode.nix
    ./wofi.nix
    ./zsh.nix
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

  # fonts.fontconfig.enable = true;
  home.packages = with pkgs; [ nerd-fonts.roboto-mono zoxide ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrains Mono Nerd Font" ];
    };
  };

  # colorScheme = inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};

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

  services.kdeconnect.enable = false;
  services.nextcloud-client.enable = false;

  # services.gnome-keyring = {
  #   enable = true;

  # };

  programs.firefox = {
    enable = true;
    # Until https://github.com/nix-community/home-manager/issues/1641 is fixed
    package = pkgs.firefox;

    nativeMessagingHosts = [
      pkgs.keepassxc
      # pkgs.vdhcoapp
      # pkgs.keepassxc-proxy
    ];

    profiles.default = { path = "1utyytkx.default"; };
  };

  # systemd.user.startServices = true;
  # systemd.user.services.squeezelite-user =
  #   let name = "workstation";
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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [ obs-studio-plugins.wlrobs ];
    # plugins = with pkgs; [ obs-studio-plugins.wlrobs (callPackage /home/raphael/Downloads/nixpkgs/pkgs/applications/video/obs-studio/plugins/obs-hyperion/default.nix { inherit (qt5) qtbase; }) ];
    # plugins = with pkgs; [ obs-studio-plugins.wlrobs obs-studio-plugins.obs-hyperion ];
  };

  services.gammastep = {
    enable = true;
    # Berlin coordinates
    latitude = "52.5200";
    longitude = "13.405";
    temperature = { night = 3000; };
    # settings = {
    #   randr = {
    #     screen = 0;
    #   };
    # };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      # "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

}

