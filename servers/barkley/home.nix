{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in
{

  home.stateVersion = "21.03";
}
