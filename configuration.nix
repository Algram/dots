# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, fetchFromGitHub, ... }:
let
  secrets = import ./secrets.nix;
  waypkgs = (import "${
      builtins.fetchTarball
      "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz"
    }/packages.nix");
in {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./loginManager.nix
    ./home.nix
    ./zsh.nix
    ./programs.nix
    ./work.nix
    ./networking.nix
    ./syncthing.nix
    ./mounts.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    loader.timeout = 1;

    plymouth.enable = true;

    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    kernelModules = [
      # Report data from the ASUS X470 motherboard
      "asus_wmi_sensors"
      # Support controlling display brightness via ddccontrol
      "i2c-dev"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
      pkgs.linuxPackages.asus-wmi-sensors
    ];

    extraModprobeConfig = ''
      options v4l2loopback video_nr=10,11 card_label="OBS","VirtualWebcam" exclusive_caps=1 devices=2
    '';
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl

        # Vulkan
        amdvlk
      ];

      # Needed for steam
      driSupport = true;
      driSupport32Bit = true;
    };

    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
  };

  hardware.openrazer.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "syncthing"
      # Required for openrazer-daemon
      "plugdev"
      "i2c"
      "i2c-dev"
      "backlight"
      # Esphome flashing
      "tty"
      "dialout"
      # ADB
      "adbusers"
    ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  time.timeZone = "Europe/Berlin";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  security.polkit.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;

    chromium = { enableWideVine = true; };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [ nerdfonts roboto roboto-mono noto-fonts ];

    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts.monospace = [ "Roboto Mono" ];
    };
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      waypkgs.xdg-desktop-portal-wlr
    ];
  };

  services.pipewire.enable = true;
  services.pipewire.socketActivation = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.gnome3.gnome-settings-daemon = { enable = true; };

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # Enable auto-mounting of usb drives in nautilus and protocol support for sftp
  services.gvfs.enable = true;

  # Enable disk utility
  services.udisks2.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  environment.variables = {
    XDG_CURRENT_DESKTOP =
      "sway"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_TYPE =
      "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };

  programs.adb.enable = true;

  programs.dconf.enable = true;

  programs.sway.enable = true;

  services.unifi = { enable = false; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

