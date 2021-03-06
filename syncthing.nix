{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  services.syncthing = {
    enable = true;
    relay.enable = false;
    user = secrets.username;
    dataDir = "/home/${secrets.username}/syncthing";
    configDir = "/home/${secrets.username}/syncthing/.config/syncthing";
    declarative = secrets.syncthing.declarative;
  };
}
