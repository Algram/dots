{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  virtualisation.docker.enable = true;

  users.users.${secrets.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    (yarn.override { nodejs = nodejs-14_x; })
    google-chrome
    postman
    cypress
    teams
    nodejs-14_x
    python
    python27Packages.pip
    python38Packages.pip
    libreoffice
    p3x-onenote
  ];
}
