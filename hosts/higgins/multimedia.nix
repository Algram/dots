{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  hardware = {
    graphics = {
      enable = true;
      # extraPackages = with pkgs; [
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      # libvdpau-va-gl
      # ];
    };
  };

  # hardware.intelgpu.vaapiDriver = "intel-media-driver";
  hardware.amdgpu.initrd.enable = true;

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

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    # wlr = {
    #   enable = true;
    #   settings = {
    #     screencast = {
    #       chooser_type = "simple";
    #       chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -ro";
    #     };
    #   };
    # };
    # extraPortals = with pkgs;
    #   [
    #     # xdg-desktop-portal-gtk
    #     # xdg-desktop-portal-wlr
    #     xdg-desktop-portal-hyprland
    #   ];
  };

  # nixpkgs.config.packageOverrides = pkgs: {
  #   intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };

  # environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # systemd.user.services.snapclient-local = {
  #   wantedBy = [
  #     "pipewire.service"
  #   ];
  #   after = [
  #     "pipewire.service"
  #   ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID living-room";
  #   };
  # };

}

