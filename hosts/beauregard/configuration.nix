# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, fetchFromGitHub, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./loginManager.nix
    # ./home.nix
    # ./zsh.nix
    ./programs.nix
    ./work.nix
    ./networking.nix
    ./mounts.nix
    ./virtualization.nix
    ./systemd.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;

  boot = {
    plymouth = {
      enable = true;
      theme = "red_loader";
      themePackages = with pkgs;
        [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "red_loader" ];
          })
        ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    # initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      # "module_blacklist=i915"
      # "video=HDMI-A-1:3840x2160@120"
      # "i915.enable_guc=2"
      # "i915.enable_fbc=1"
      # "i915.enable_psr=2"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd = {
      verbose = false;
      kernelModules = [ "amdgpu" ];
    };

    # kernelPackages = pkgs.linuxPackages_5_4;
    kernelPackages = pkgs.linuxPackages_latest;

    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    kernelModules = [
      # Report data from the ASUS X470 motherboard
      # "asus_wmi_sensors"
      # Support controlling display brightness via ddccontrol
      "i2c-dev"
      # Bluetooth USB dongle support
      "btusb"
      "v4l2loopback"
    ];
    extraModulePackages = [
      #config.boot.kernelPackages.v4l2loopback
      # config.boot.kernelPackages.asus-wmi-sensors
    ];
  };

  # boot = {
  #   # Use the systemd-boot EFI boot loader.
  #   loader.systemd-boot = {
  #     enable = true;
  #     consoleMode = "auto";
  #   };
  #   loader.efi.canTouchEfiVariables = true;

  #   loader.timeout = 1;

  #   plymouth.enable = true;

  #   initrd = {
  #     verbose = false;
  #     kernelModules = [ "amdgpu" ];
  #   };

  #   # kernelPackages = pkgs.linuxPackages_5_4;
  #   kernelPackages = pkgs.linuxPackages_latest;

  #   kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
  #   kernelModules = [
  #     # Report data from the ASUS X470 motherboard
  #     "asus_wmi_sensors"
  #     # Support controlling display brightness via ddccontrol
  #     "i2c-dev"
  #     # Bluetooth USB dongle support
  #     "btusb"
  #     "v4l2loopback"
  #   ];
  #   extraModulePackages = [
  #     config.boot.kernelPackages.v4l2loopback
  #     config.boot.kernelPackages.asus-wmi-sensors
  #   ];

  #   # extraModprobeConfig = ''
  #   #   options v4l2loopback exclusive_caps=1 video_nr=9 card_label=VirtualVideoDevice
  #   # '';
  # };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl ];

      # Needed for Steam
      # driSupport = true;
      # driSupport32Bit = true;
    };

    # Replaced by pipewire
    # Pulseaudio needed for PS4 bluetooth controller

  };

  services.shairport-sync.enable = false;
  services.shairport-sync.openFirewall = true;
  services.shairport-sync.settings = { general.output_backend = "pw"; };

  services.pulseaudio.enable = false;
  services.pulseaudio.support32Bit = true;

  services.flatpak.enable = true;

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

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    # packages = with pkgs; [ nerd-fonts.roboto-mono ];
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-mono
      nerd-fonts.roboto-mono
    ];

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

  nixpkgs.config.permittedInsecurePackages =
    [ "libsoup-2.74.3" "qtwebengine-5.15.19" ];

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
      # settings = {
      #   screencast = {
      #     chooser_type = "simple";
      #     chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -ro";
      #   };
      # };
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
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
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

  # systemd.user.services.snapclient-local = {
  #   wantedBy = [ "pipewire.service" ];
  #   after = [ "pipewire.service" ];
  #   serviceConfig = {
  #     ExecStart =
  #       "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID workstation";
  #   };
  # };

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
  services.dbus.enable = true;

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

  services.fwupd.enable = true;

  programs.dconf.enable = true;

  # Needed for login manager session file
  programs.sway.enable = true;
  programs.sway.package = null;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  # hardware.bluetooth.package = pkgs.bluez.overrideAttrs (oldAttrs: {
  #   configureFlags = oldAttrs.configureFlags ++ [ "--enable-sixaxis" ];
  # });

  services.jellyfin.enable = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
    pkgs.jellyfin-media-player
    # (pkgs.makeDesktopItem {
    #   name = "twitch";
    #   exec = "firefox --new-window --kiosk https://twitch.tv";
    #   icon = "firefox";
    #   desktopName = "Twitch";
    #   comment = "Launch Twitch.tv in a dedicated browser window";
    #   categories = [ "Network" "Video" ];
    # })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

