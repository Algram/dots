{ config, pkgs, ... }:
let
  # nix-software-center = import (pkgs.fetchFromGitHub {
  #   owner = "vlinkz";
  #   repo = "nix-software-center";
  #   rev = "0.1.2";
  #   sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  # }) {};

  #    pkgs2 = import (builtins.fetchGit {
  #      # Descriptive name to make the store path easier to identify
  #      name = "my-old-revision";
  #      url = "https://github.com/NixOS/nixpkgs/";
  #      ref = "refs/heads/nixpkgs-unstable";
  #      rev = "e89cf1c932006531f454de7d652163a9a5c86668";
  #  }) {};

  #  myPkg = pkgs2.kodiPackages.kodi;
in {
  nixpkgs.config = {
    allowUnfree = true;
    chromium.enableWideVine = true;
  };

  programs.steam.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override { extraPkgs = pkgs: with pkgs; [ pipewire ]; };
  };

  programs.java = { enable = true; };

  services.accounts-daemon.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  services.ollama = {
    enable = false;
    environmentVariables = {
      HCC_AMDGPU_TARGET =
        "gfx1010"; # used to be necessary, but doesn't seem to anymore
    };
    rocmOverrideGfx = "10.1.0";
  };

  # services.squeezelite.enable = true;
  # services.squeezelite.pulseAudio = true;

  services.sunshine = {
    enable = false;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

  };

  environment.systemPackages = with pkgs; [
    # nix-software-center
    qt5.qtwayland
    # For vscode nix file formatting
    # nixfmt
    # playwright
    #  playwright.browsers
    terraform
    # mgba
    (pkgs.steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; })
    appimage-run
    fdupes
    # telegram-desktop
    ddccontrol
    wol
    sc-controller
    nixfmt-rfc-style
    d-spy
    # blender
    discord
    dropbox
    alsa-utils # For volume control script
    esphome
    # libcec
    arduino
    # platformio
    xournalpp
    # inkscape
    orca-slicer
    helvum
    moonlight-qt
    # parsec-bin
    # evolution
    gnumake
    gcc
    cmake
    # opencv
    # hyperhdr
    # esphome_pr
    # For pactl
    gnome-control-center
    ddcui
    # mediawriter
    pulseaudio
    pamixer # For volume control script
    ffmpeg-full
    alsa-lib
    # firefox-wayland
    # (firefox-wayland.override { cfg.enableKeePassXC = true; })
    gimp
    git
    glib
    adwaita-icon-theme
    evince
    file-roller
    gedit
    gnome-disk-utility
    gnome-keyring
    seahorse
    gnome-logs
    # nix-output-monitor
    # blender
    xorg.xrandr # needed for xrandr --output DP-1 --primary
    # gnome-system-monitor
    android-tools
    nautilus
    gnome-calendar
    planify
    ripgrep
    bat
    eza
    # Modern CLI tools
    delta # Better git diff
    tokei # Code statistics
    bottom # System monitor
    dust # Disk usage analyzer
    procs # Better ps
    lazygit # Git TUI
    btop
    pinta
    mission-center
    fd
    blueberry
    wofi
    shotwell
    gnupg
    gopass
    grim
    gsettings-desktop-schemas
    gtk_engines
    gtk-engine-murrine
    gtk3
    imagemagick
    jq
    keepassxc
    kitty
    libnfs
    libnotify
    libusb1
    openscad
    lm_sensors
    # lutris
    mpv
    neovim
    networkmanager
    networkmanager-openconnect
    networkmanagerapplet
    nfs-utils
    pavucontrol
    gnome-software
    # pinentry-gnome
    polkit
    polkit_gnome
    # prusa-slicer
    # super-slicer-latest
    sov
    xdg-desktop-portal-wlr
    # pulseeffects-legacy
    pywal
    rrsync
    signal-desktop
    slurp
    sox
    # spotify
    # kicad
    nextcloud-client
    # mullvad
    sshfs
    scrcpy
    swappy
    razergenie
    # ungoogled-chromium # chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
    unzip
    v4l-utils
    # wireguard-tools
    # wireshark
    wl-clipboard
    wtype
    xdotool
    xsettingsd
    # Deprecated. Remove daemon from sway as well
    ydotool
    yt-dlp
    # LOL Lutris
    openssl
    bluez
    # hyperion-ng
    # hyperhdr
    pika-backup
    # drawing
    # element-desktop-wayland
    # element-web
    obsidian
    appimage-run
    cheese
    ipmitool
    # minecraft
    # prismlauncher
    # modrinth-app
    # gnome.mission-control
    # pass-wayland
    keepmenu
    # rpi-imager
    # kodi
    # micromamba
    # myPkg
    # kodi-wayland
  ];

  #   services.plex = {
  #   enable = true;
  #   openFirewall = true;
  # };
}
