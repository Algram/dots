{ config, pkgs, lib, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.enso.enable = true;
  };
  services.xserver.libinput.enable = true;
  services.xserver.layout = "us";
}
