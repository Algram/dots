# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, fetchFromGitHub, ... }:
let
  secrets = import ./secrets.nix;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  waypkgs = (import "${builtins.fetchTarball https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz}/packages.nix");
in
{
  imports =
    [
      ./hardware-configuration.nix  # Include the results of the hardware scan.
      ./loginManager.nix
      ./zsh.nix
      ./programs.nix
      ./work.nix
      ./networking.nix
      ./syncthing.nix
      ./wofi.nix
      (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos") 
   ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    loader.timeout = 1;

    # plymouth.enable = true;

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
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
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

  systemd.services = {
    tune-usb-autosuspend = {
      description = "Disable USB autosuspend";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; };
      unitConfig.RequiresMountsFor = "/sys";
      script = ''
        echo -1 > /sys/module/usbcore/parameters/autosuspend
      '';
    };
  };

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

    chromium = {
      enableWideVine = true;
    };
  };

  services.rpcbind.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [
      nerdfonts
      roboto
      roboto-mono
      noto-fonts
    ];

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

  services.gnome3.gnome-settings-daemon = {
    enable = true;
  };

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # Enable auto-mounting of usb drives in nautilus and protocol support for sftp
  services.gvfs.enable = true;

  # Enable disk utility
  services.udisks2.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
  };

  environment.variables = {
    XDG_CURRENT_DESKTOP = "sway";# https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_TYPE = "wayland";# https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };
  
  programs.dconf.enable = true;

  programs.sway.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${secrets.username} = { pkgs, ... }: {
    imports = [
      ./sway.nix
      ./mako.nix
      ./waybar.nix
      ./kitty.nix
      ./rofi.nix
      # "${fetchTarball "https://github.com/msteen/nixos-vsliveshare/tarball/master"}/modules/vsliveshare/home.nix"
    ];

  #     services.vsliveshare = {
  #   enable = true;
  #   extensionsDir = "$HOME/.vscode/extensions";
  #   nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/61cc1f0dc07c2f786e0acfd07444548486f4153b";
  # };

    home.sessionVariables = {
      # Fix antialasing ?
      FREETYPE_PROPERTIES = truetype:interpreter-version=35;
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_CURRENT_DESKTOP = "sway";# https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
      XDG_SESSION_TYPE = "wayland";# https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
    };

    fonts.fontconfig.enable = true;

    # home.packages = [
    #   pkgs.nerdfonts
    #   pkgs.roboto
    #   pkgs.roboto-mono
    #   pkgs.noto-fonts
    # ];

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

    # programs.firefox = {
    #   enable = true;
      # package = pkgs.firefox-wayland;
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   https-everywhere
      #   privacy-badger
      #   ublock-origin
      #   decentraleyes
      # ];
    # };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ waypkgs.obs-wlrobs obs-v4l2sink ];
    };

    services.gammastep = {
      enable = true;
      # Berlin coordinates
      latitude = "52.5200";
      longitude = "13.405";
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "file-icons";
          publisher = "file-icons";
          version = "1.0.24";
          sha256 = "0mcaz4lv7zb0gw0i9zbd0cmxc41dnw344ggwj1wy9y40d627wdcx";
        }
        {
          name = "vscode-eslint";
          publisher = "dbaeumer";
          version = "2.1.6";
          sha256 = "0xllvrpmxgpmn5f1w8b3gapfyv84r5c3mqy76w5mwcv0snm0981w";
        }
        {
          name = "daily";
          publisher = "sldobri";
          version = "6.0.3";
          sha256 = "0fxin3wq1ysgz4lzpjlal3lba3qd48z5dbqkppyvmg2cvrw500ii";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "10.2.2";
          sha256 = "00fp6pz9jqcr6j6zwr2wpvqazh1ssa48jnk1282gnj5k560vh8mb";
        }
        {
          name = "graphql-for-vscode";
          publisher = "kumar-harsh";
          version = "1.15.3";
          sha256 = "1x4vwl4sdgxq8frh8fbyxj5ck14cjwslhb0k2kfp6hdfvbmpw2fh";
        }
        {
          name = "mdx";
          publisher = "silvenon";
          version = "0.1.0";
          sha256 = "1mzsqgv0zdlj886kh1yx1zr966yc8hqwmiqrb1532xbmgyy6adz3";
        }
        {
          name = "vscode-mdx-preview";
          publisher = "xyc";
          version = "0.3.0";
          sha256 = "15xbr05a5gj3ncfmb0878bfq1xhyncz31z5hizlq68bnlk3kd1pa";
        }
        {
          name = "prettier-vscode";
          publisher = "esbenp";
          version = "5.1.3";
          sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
        }
      ];
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

