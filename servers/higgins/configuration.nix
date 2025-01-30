# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.sway}/bin/sway";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./boot.nix
    ./wol.nix
    ./multimedia.nix
  ];

  services.gnome.gnome-keyring.enable = true;



  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = secrets.hostname;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fwupd.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [ "wheel" "docker" "video" "audio" "pipewire" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  nixpkgs.config.allowUnfree = true;

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
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      customPkgs = with pkgs; [ spaceship-prompt ];
      theme = "spaceship";
      plugins = [ "git" "z" ];
    };
  };

  services.tlp = {
    enable = true;
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

  environment.systemPackages = with pkgs; [
    rrsync
    vim
    zsh
    git
    powertop
    htop
    ethtool
    hyperhdr
    kitty # required for the default Hyprland config
    uwsm
    # kodi
    (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
      inputstream-adaptive
      youtube
      # twitch
      sendtokodi
    ]))
    pavucontrol
    firefox
    mpv
    nautilus
    libdrm
  ];

  security.polkit.enable = true;

  programs = {
    xwayland = {
      enable = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

