{ config, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    chromium.enableWideVine = true;
  };
 
  programs.steam.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pipewire
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    # For vscode nix file formatting
    nixfmt
    # playwright
    #  playwright.browsers
    terraform
    (pkgs.steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; })
    appimage-run
    ddccontrol
    dfeet
    discord
    dropbox
    alsa-utils # For volume control script
    esphome
    libcec
    arduino
    platformio
    # esphome_pr
    # For pactl
    gnome.gnome-control-center
    ddcui
    etcher
    pulseaudio
    pamixer # For volume control script
    ffmpeg-full
    alsaLib
    firefox-wayland
    gimp
    git
    glib
    gnome.adwaita-icon-theme
    gnome.evince
    gnome.file-roller
    gnome.gedit
    gnome.gnome-disk-utility
    gnome.gnome-keyring
    gnome.seahorse
    gnome.gnome-logs
    gnome.gnome-system-monitor
    gnome.nautilus
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
    lutris
    mpv
    neovim
    networkmanager
    networkmanager-openconnect
    networkmanagerapplet
    nfs-utils
    pavucontrol
    pinentry-gnome
    polkit
    polkit_gnome
    prusa-slicer
    super-slicer-latest
    # pulseeffects-legacy
    pywal
    rrsync
    signal-desktop
    slurp
    sox
    spotify
    kicad
    sshfs
    scrcpy
    swappy
    razergenie
    ungoogled-chromium # chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
    unzip
    v4l-utils
    wireguard-tools
    wireshark
    wl-clipboard
    wtype
    xdotool
    xsettingsd
    # Deprecated. Remove daemon from sway as well
    ydotool
    youtube-dl
    # LOL Lutris
    openssl
    bluez
    hyperion-ng
    # hyperhdr
    pika-backup
    drawing
    element-desktop-wayland
    element-web
    obsidian
    appimage-run
  ];
}
