{ config, pkgs, ... }: {
  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;
  virtualisation.incus.package = pkgs.incus;
  networking.nftables.enable = true;
}
