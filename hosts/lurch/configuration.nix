{ modulesPath, lib, pkgs, ... }@args:
let secrets = import ./secrets.nix;
in {
  imports = [ ./disk-config.nix ];

  networking.hostId = "8425e349";

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
      "acme"
      "bluetooth"
      "incus-admin"
    ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aliasgram@gmail.com";
    certs.wildcard = {
      dnsProvider = "cloudflare";
      group = "nginx";
      domain = "*.${secrets.domain}";
      dnsResolver = "1.1.1.1:53";
      credentialsFile = builtins.toFile "cloudflare-acme-credentials.env"
        secrets.acme.cloudflare.credentials;
    };
  };

  fileSystems."/mnt/immich/data" = {
    device = "192.168.1.150:/mnt/tank/immich/data";
    fsType = "nfs";
  };

  fileSystems."/mnt/immich/external-library" = {
    device = "192.168.1.150:/mnt/tank/immich/external-library";
    fsType = "nfs";
  };

  services.nginx.enable = true;

  services.nginx.virtualHosts."immich.${secrets.domain}" = {
    # enableACME = true;
    useACMEHost = "wildcard";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:2283";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };

  services.immich.mediaLocation = "/mnt/immich/data";
  services.immich.enable = true;
  services.immich.port = 2283;
  services.immich.openFirewall = false;

  services.immich.accelerationDevices = null;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Optionally, set the environment variable

  users.users.immich.extraGroups = [ "video" "render" ];
}
