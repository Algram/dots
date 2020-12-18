{ config, pkgs, ... }: 
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  waypkgs = (import "${builtins.fetchTarball https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz}/packages.nix");
in {
  environment.systemPackages = with pkgs; [
      (steam.override {
    nativeOnly = true;
  }).run
    waypkgs.wlogout
    steam
    youtube-dl
    # firefox
    # firefox-wayland Does currently not support Firefox Multi Account Containers
    libnfs
    nfs-utils
    liblockfile
    wireshark
    jq
    imagemagick
    ffmpeg-full
    arduino
    rustup
    ddccontrol
    discord
    dropbox
    unstable.firefox-wayland
    gnome3.gnome-disk-utility
    # DBus debugging tool
    dfeet
    git
    unstable.razergenie
    glib
    gnome3.adwaita-icon-theme
    gnome3.gedit
    gnome3.gnome-keyring
    gnome3.gnome-screenshot
    gnome3.gnome-system-monitor
    gnome3.gnome-tweak-tool
    gnome3.gnome-logs
    gnome3.libsecret
    gnome3.nautilus
    gnome3.shotwell
    gnome3.eog
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
    pulseeffects
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
