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
    # ./home.nix
    ./zsh.nix
    ./programs.nix
    ./work.nix
    ./networking.nix
    ./syncthing.nix
    ./mounts.nix
    ./virtualization.nix
    ./systemd.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
      "v4l2loopback"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
      config.boot.kernelPackages.asus-wmi-sensors
    ];

    # extraModprobeConfig = ''
    #   options v4l2loopback exclusive_caps=1 video_nr=9 card_label=VirtualVideoDevice
    # '';
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];

      # Needed for Steam
      # driSupport = true;
      # driSupport32Bit = true;
    };

    # Replaced by pipewire
    # Pulseaudio needed for PS4 bluetooth controller
    pulseaudio.enable = false;
    pulseaudio.support32Bit = true;
  };

  hardware.openrazer = {
    enable = true;
    users = [ secrets.username ];
    batteryNotifier.enable = false;
  };

  # hardware.bluetooth.enable = true;
  # services.blueman.enable = true;

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
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [ (nerdfonts.override { fonts = [ "RobotoMono" ]; }) ];

    # fontconfig = {
    #   enable = true;
    #   antialias = true;
    #   hinting.autohint = true;
    #   defaultFonts.monospace = [ "Roboto Mono" ];
    # };

      # fontconfig = {
      #   # Fixes pixelation
      #   antialias = true;

      #   # Fixes antialiasing blur
      #   hinting = {
      #     enable = true;
      #     style = "hintfull"; # no difference
      #     autohint = true; # no difference
      #   };

      #   subpixel = {
      #     # Makes it bolder
      #     rgba = "rgb";
      #     lcdfilter = "default"; # no difference
      #   };
      # };
  };

           nixpkgs.config.permittedInsecurePackages = [
                # "python-2.7.18.6"
                "python-2.7.18.7"
                "electron-19.1.9"
                "electron-25.9.0"
                "python-2.7.18.8"
                "python3.12-youtube-dl-2021.12.17"
                "jitsi-meet-1.0.8043"
              ];

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns4 = true;

  # https://github.com/NixOS/nixpkgs/issues/156830#issuecomment-1022400623
  xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -ro";
          };
        };
        # settings = {
        #   screencast = {
            
        #     # output_name = "eDP-1";
        #     max_fps = 30;
        #     # exec_before = "pkill mako";
        #     # exec_after = "mako";
        #     chooser_type = "none";
        #     output_name = "HDMI-A-1";

        #   #             chooser_type = "simple";
        #   # chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        #   };
        #           screencast = { 
        #   max_fps = 30; 
        #   chooser_type = "simple";
        #   chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        # };
          # };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };


    systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID workstation";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;

  services.gnome.gnome-settings-daemon = { enable = true; };

  services.dbus.packages = [ pkgs.dconf ];

  # Enable auto-mounting of usb drives in nautilus and protocol support for sftp
  services.gvfs.enable = true;

  # Enable disk utility
  services.udisks2.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
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
  programs.sway.package = null;


  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
    hardware.bluetooth.package = pkgs.bluez.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-sixaxis" ];
  });

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

