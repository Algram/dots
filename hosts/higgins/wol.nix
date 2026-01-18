{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  networking.interfaces.eno1.wakeOnLan = { enable = true; };

  # Use a systemd service to persist the setting
  systemd.services.wol = {
    description = "Enable Wake-on-LAN";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
