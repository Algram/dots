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
  ];

  # security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  boot = {

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

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

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    # hardware.graphics since NixOS 24.11
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # services.cron = {
  #   enable = false;
  #   systemCronJobs = [
  #     ''0 1 * * *     root   podman exec --user "$(id -u):$(id -g)" -it influxdb influx backup /home/influxdb/backup/ -t ${secrets.influxdb.admin.token}''
  #   ];
  # };

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

  services.gvfs.enable = true;

  # programs.hyprland.enable = false; # enable Hyprland
  # programs.hyprland.xwayland.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${secrets.username}";
      };
      default_session = {
        # https://brad-x.com/posts/quick-tip-setting-the-color-space-value-in-wayland/
        command = "proptest -M i915 -D /dev/dri/card1 112 connector 101 1 && ${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
        user = "greeter";
      };
    };
  };


  systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID living-room";
    };
  };

  #       systemd.user.services.snapcast-sink = {
  #   wantedBy = [
  #     "pipewire.service"
  #   ];
  #   after = [
  #     "pipewire.service"
  #   ];
  #   bindsTo = [
  #     "pipewire.service"
  #   ];
  #   path = with pkgs; [
  #     gawk
  #     pulseaudio
  #   ];
  #   script = ''
  #     pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
  #   '';
  # };

  #   systemd.services.kodi = let
  #   package = pkgs.kodi-gbm.withPackages (kodiPkgs: [
  #     kodiPkgs.inputstream-adaptive
  #     kodiPkgs.netflix
  #     kodiPkgs.sendtokodi
  #     kodiPkgs.youtube
  #   ]);
  # in {
  #   description = "Kodi media center";

  #   wantedBy = ["multi-user.target"];
  #   after = [
  #     "network-online.target"
  #     "sound.target"
  #     "systemd-user-sessions.service"
  #   ];
  #   wants = [
  #     "network-online.target"
  #   ];

  #   serviceConfig = {
  #     Environment = [
  # "DISPLAY=:0.0"
  # "WAYLAND_DISPLAY=wayland-0"
  #     ];
  #     Type = "simple";
  #     User = "higgins";
  #     ExecStart = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  #     Restart = "always";
  #     TimeoutStopSec = "15s";
  #     TimeoutStopFailureMode = "kill";

  #     # Hardening

  #   };
  # };

  #  security.polkit = {
  #     extraConfig = ''
  #       polkit.addRule(function(action, subject) {
  #               return polkit.Result.YES;s
  #       });
  #     '';
  #   };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };


  # services.xserver.enable = true;
  # services.xserver.desktopManager.kodi.enable = true;
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "higgins";
  # services.xserver.displayManager.lightdm.greeter.enable = false;

  # Define a user account
  # users.extraUsers.kodi.isNormalUser = true;

  # users.extraUsers.kodi.isNormalUser = true;
  # # users.extraUsers.kodi.extraGroups = [ "data" "video" "audio" "input" ];
  # services.cage.user = "higgins";
  # services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  # services.cage.enable = true;

  services.pipewire = {
    enable = true;
    socketActivation = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  security.polkit.enable = true;

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
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
    ];
  };

  programs = {
    # hyprland = {
    #   enable = true;
    # };
    xwayland = {
      enable = true;
    };
  };

  networking.interfaces.enp0s31f6.wakeOnLan = {
    enable = true;
  };

  # Use a systemd service to persist the setting
  systemd.services.wol = {
    description = "Enable Wake-on-LAN";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp0s31f6 wol g";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
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

