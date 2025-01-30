{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in
{
  virtualisation.docker.enable = true;

  users.users.${secrets.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    (yarn.override { nodejs = nodejs-18_x; })
    google-chrome
    nodejs-18_x
    python
    # python38Packages.pip
    libreoffice
    nodePackages.pnpm
  ];
}
