{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = [ "kvm-amd" ];
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];
  users.users.${secrets.username}.extraGroups = [ "libvirtd" ];
}
