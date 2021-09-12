{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  networking = {
    hostName = secrets.hostname;
    extraHosts = secrets.networking.extraHosts;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp6s0.useDHCP = true;
    networkmanager = { enable = true; };


    # KDE Connect
    # firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    # firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
}
