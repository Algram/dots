{ config, pkgs, ... }: 
let
  secrets = import ./secrets.nix;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  services.syncthing = {
    enable = true;
    package = unstable.syncthing;
    relay.enable = false;
    user = secrets.username;
    dataDir = "/home/${secrets.username}/syncthing";
    configDir = "/home/${secrets.username}/syncthing/.config/syncthing";
    declarative = secrets.syncthing.declarative;
  };
}
