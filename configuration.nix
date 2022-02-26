# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, fetchFromGitHub, ... }:
let
  secrets = import ./secrets.nix;
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
    ./virtualization.nix
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot = {
      enable = true;
      consoleMode = "auto";
    };
    loader.efi.canTouchEfiVariables = true;

    loader.timeout = 1;

    plymouth.enable = true;

    initrd = {
      verbose = false;
      kernelModules = [ "amdgpu" ];
    };

    # kernelPackages = pkgs.linuxPackages_5_4;
    kernelPackages = pkgs.linuxPackages_latest;

    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    kernelModules = [
      # Report data from the ASUS X470 motherboard
      "asus_wmi_sensors"
      # Support controlling display brightness via ddccontrol
      "i2c-dev"
      # Bluetooth USB dongle support
      "btusb"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
      config.boot.kernelPackages.asus-wmi-sensors
    ];
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];

      # Needed for Steam
      driSupport = true;
      driSupport32Bit = true;
    };

    # Replaced by pipewire
    pulseaudio.enable = false;
    pulseaudio.support32Bit = false;
  };

  hardware.openrazer = {
    enable = true;
    users = [ secrets.username ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware.enableRedistributableFirmware = true;

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
    allowBroken = false;

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

    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "RobotoMono" ]; }) roboto roboto-mono noto-fonts noto-fonts-emoji ];

    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts.monospace = [ "Roboto Mono" ];
    };
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  # xdg.portal = {
  #   enable = true;
  #   gtkUsePortal = true;

  #   extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-wlr ];
  # };

  # https://github.com/NixOS/nixpkgs/issues/156830#issuecomment-1022400623
  xdg.portal =
    let
      gnome = config.services.xserver.desktopManager.gnome.enable;
    in
    {
      enable = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            # output_name = "eDP-1";
            max_fps = 30;
            # exec_before = "pkill mako";
            # exec_after = "mako";
            chooser_type = "default";
          };
        };
      };
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ]
        ++ lib.optional (!gnome) pkgs.xdg-desktop-portal-gtk;
      gtkUsePortal = false;
    };

  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.gnome.gnome-settings-daemon = { enable = true; };

  services.dbus.packages = [ pkgs.dconf ];

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

  services.fwupd.enable = true;

  programs.dconf.enable = true;

  # Needed for login manager session file
  programs.sway.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

