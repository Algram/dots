{ config, pkgs, ... }: {
  # boot.loader.grub = {
  #   # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  #   devices = [ "/dev/sda" ];
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  # };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot = {
    # Newest kernels might not be supported by ZFS
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # ZFS does not support swapfiles, disable hibernate and set cache max
    kernelParams = [ "nohibernate" "zfs.zfs_arc_max=17179869184" ];
    supportedFilesystems = [ "vfat" "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-id/";
      forceImportAll = true;
      requestEncryptionCredentials = true;
    };
  };

  systemd.services.zfs-mount.enable = true;

  services.openssh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      # customPkgs = with pkgs; [ spaceship-prompt ];
      # theme = "starship";
      plugins = [ "git" "z" ];
    };
  };

  # ---------INCUS--------------

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 8443 3000 ];

  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # networking.vlans = {
  #   lab = {
  #     id = 148;
  #     interface = "eno1";
  #   };
  # };

  system.stateVersion = "24.05";
}
