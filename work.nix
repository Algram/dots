{ config, pkgs, ... }: 
let
  secrets = import ./secrets.nix;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  # networking = {
  #   extraHosts = "";
  # };

  virtualisation.docker.enable = true;

  users.users.${secrets.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    (yarn.override { nodejs = nodejs-14_x; })
    google-chrome
    postman
    cypress
    teams
    nodejs-12_x
    python
    python27Packages.pip
    python38Packages.pip
    libreoffice
  ];
}
