{ config, pkgs, ... }:
let
  waypkgs = (import "${
      builtins.fetchTarball
      "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz"
    }/packages.nix");
in {
  nixpkgs.config = {
    allowUnfree = true;
    chromium.enableWideVine = true;
  };

  environment.systemPackages = with pkgs; [
    (steam.override { nativeOnly = true; }).run
    appimage-run
    ddccontrol
    dfeet
    discord
    dropbox
    esphome
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
    gnome3.libsecret
    gnome3.nautilus
    gnome3.shotwell
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
    numix-icon-theme-circle
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
    waypkgs.wlogout
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
