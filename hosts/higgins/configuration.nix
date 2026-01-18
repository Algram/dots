# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./boot.nix
    ./wol.nix
    ./multimedia.nix
  ];

  services.gnome.gnome-keyring.enable = true;

  services.gnome.gnome-settings-daemon = { enable = true; };

  services.dbus.packages = [ pkgs.dconf ];
  services.dbus.enable = true;
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  security.pam.loginLimits = [{
    domain = "@users";
    item = "rtprio";
    type = "-";
    value = 1;
  }];

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    # XDG_CURRENT_DESKTOP =
    #   "hyprland"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    # XDG_SESSION_TYPE =
    #   "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };

  # Needed for login manager session file
  programs.sway.enable = false;
  programs.sway.wrapperFeatures.gtk = true;
  programs.sway.package = null;

  services.blueman.enable = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  networking.hostName = secrets.hostname;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fwupd.enable = false;

  # users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups =
      [ "wheel" "docker" "video" "audio" "pipewire" "input" "storage" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  # nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.zsh = {
    enable = true;
    # autosuggestions.enable = true;
    # syntaxHighlighting.enable = true;

    # ohMyZsh = {
    #   enable = true;
    #   customPkgs = with pkgs; [ spaceship-prompt ];
    #   theme = "spaceship";
    #   plugins = [ "git" "z" ];
    # };
  };

  services.tlp = {
    enable = false;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      WOL_DISABLE = "N";
      # CPU_MAX_PERF_ON_AC = 30;
      CPU_MAX_PERF_ON_BAT = 30;
    };
  };

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.autoUpgrade.enable = false;

  fileSystems."/mnt/media" = {
    device = "192.168.1.150:/mnt/data/media";
    fsType = "nfs";
  };

  programs.hyprland = {
    enable = true;
    # set the flake package
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [

    bc # Needed for denon volume script
    rrsync
    vim
    zsh
    git
    powertop
    wev
    # Notify-Send needs glib gdbus
    glib
    htop
    ethtool
    hyperhdr
    kitty # required for the default Hyprland config
    uwsm
    makima
    evtest
    pamixer
    kodi
    # (pkgs.kodi.withPackages (kodiPkgs:
    #   with kodiPkgs; [
    #     inputstream-adaptive
    #     youtube
    #     # twitch
    #     sendtokodi
    #   ]))
    pavucontrol
    firefox
    mpv
    nautilus
    libdrm
    nfs-utils
    libnfs
    lm_sensors
    gnome-software
    antimicrox
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    # jellyfin-media-player
    jq
    usbutils
    wayvnc
    # plasma-bigscreen
    # hashcat
    # rocm
    squeekboard
    gsettings-desktop-schemas
    vlc
    wlr-randr
    xorg.xrandr
    sc-controller
    glib
    gtk3
    slurp
    grim
  ];

  hardware.steam-hardware.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  programs = { xwayland = { enable = true; }; };

  services.jellyfin.enable = true;
  services.jellyfin.user = "${secrets.username}";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  # networking.useDHCP = false;
  # networking.networkmanager.enable = false;
  # systemd.network.enable = true;
  # networking.interfaces.eno1.useDHCP = false;
  # systemd.network.wait-online.enable = true;

  # systemd.network.networks."50-eno1" = {
  #   name = "eno1";
  #   matchConfig.Name = "eno1";
  #   # acquire a DHCP lease on link up
  #   # networkConfig.DHCP = "ipv4";
  #   # linkConfig.LinkLocalAddressing = "ipv4";
  #   # this port is not always connected and not required to be online
  #   # linkConfig.RequiredForOnline = "no";

  #   address = [ "192.168.1.153/24" ];
  #   routes = [{ Gateway = "192.168.1.1"; }];
  #   linkConfig.RequiredForOnline = "routable";
  # };

  # networking.hosts."192.168.1.152" = [ "home.raphael.sh" ];
  # 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

