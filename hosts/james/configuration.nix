{ modulesPath, lib, pkgs, ... }@args:
let secrets = import ./secrets.nix;
in {
  imports = [ ./disk-config.nix ];

  networking.hostId = "8425e339";

  users.users.root.openssh.authorizedKeys.keys =
    secrets.openssh.authorizedKeys.keys;

  networking.hostName = secrets.hostname;
  users.users.${secrets.username} = {
    linger = true;
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [
      "wheel"
      "docker"
      "postgres"
      "libvirtd"
      "audio"
      "bluetooth"
      "incus-admin"
    ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };
}
