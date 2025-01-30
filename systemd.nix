{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in
{
  systemd.services.notify-on-shutdown = {
    enable = true;
    description = "Notify on shutdown";
    unitConfig = {
      Requires = "network-online.target";
      After = "network-online.target";
    };
    serviceConfig = {
      ExecStop = "/etc/nixos/dotfiles/scripts/notify-node-red.sh";
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "default.target" ];
  };
}
