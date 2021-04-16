{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
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
    wtype
    (steam.override { nativeOnly = true; }).run
    sshfs
    spotify
    signal-desktop
    lutris
    esphome
    waypkgs.wlogout
    steam
    youtube-dl
    # firefox Does currently not support Firefox Multi Account Containers
    firefox-wayland
    libnfs
    nfs-utils
    wireshark
    jq
    imagemagick
    ffmpeg-full
    swappy
    rustup
    ddccontrol
    discord
    dropbox
    gnome3.gnome-disk-utility
    # DBus debugging tool
    dfeet
    git
    unstable.razergenie
    glib
    gnome3.adwaita-icon-theme
    gnome3.gedit
    gnome3.gnome-keyring
    gnome3.gnome-system-monitor
    gnome3.gnome-logs
    gnome3.libsecret
    gnome3.nautilus
    gnome3.shotwell
    gnome3.file-roller
    gnome3.evince
    gnupg
    gopass
    grim
    gtk-engine-murrine
    gtk_engines
    xsettingsd
    gsettings-desktop-schemas
    gtk3
    hidapi
    keepassxc
    kitty
    libnotify
    libusb
    lm_sensors
    mpv
    gimp
    neovim
    networkmanager
    networkmanager-openconnect
    networkmanagerapplet
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
    unstable.ungoogled-chromium
    vim
    vulkan-loader
    wireguard
    wl-clipboard
    xdotool
    xsettingsd
    ydotool
    v4l-utils
    unzip
    appimage-run
  ];
}
