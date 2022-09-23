{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  virtualisation.docker.enable = true;

  users.users.${secrets.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    (yarn.override { nodejs = nodejs-16_x; })
    google-chrome
    nodejs-16_x
    python
    python27Packages.pip
    python38Packages.pip
    libreoffice
  ];
}
