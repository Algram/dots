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
    terraform
    (pkgs.steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; })
    appimage-run
    ddccontrol
    dfeet
    discord
    dropbox
    alsa-utils # For volume control script
    esphome
    # For pactl
    pulseaudio
    pamixer # For volume control script
    ffmpeg-full
    firefox-wayland
    gimp
    git
    glib
    gnome3.adwaita-icon-theme
    gnome3.evince
    gnome3.file-roller
    gnome3.gedit
    gnome3.gnome-disk-utility
    gnome3.gnome-keyring
    gnome3.gnome-logs
    gnome3.gnome-system-monitor
    gnome3.nautilus
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
    libusb
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
    pulseeffects-legacy
    pywal
    rrsync
    signal-desktop
    slurp
    sox
    spotify
    sshfs
    swappy
    razergenie
    ungoogled-chromium
    unzip
    v4l-utils
    wireguard
    wireshark
    wl-clipboard
    wtype
    xdotool
    xsettingsd
    ydotool
    youtube-dl
  ];
}
