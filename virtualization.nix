{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in
{
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = [ "kvm-amd" ];
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager bottles ]; #bottles
  users.users.${secrets.username}.extraGroups = [ "libvirtd" ];
  virtualisation.spiceUSBRedirection.enable = true;
}
