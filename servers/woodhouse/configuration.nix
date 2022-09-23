# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = secrets.hostname;
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.fwupd.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  nixpkgs.config.allowUnfree = true;

  services.unifi.enable = true;
  services.unifi.openPorts = false;
  services.unifi.unifiPackage = pkgs.unifiStable;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  time.timeZone = "Europe/Berlin";
  
  services.mosquitto.enable = true;
  services.mosquitto.listeners = [
    {
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
      acl = [ "topic readwrite #" "pattern readwrite #" ];
      users = {};
    }
    # {
    #   port = 8883;
    #   users.openwb = {
    #     # acl = [ "pattern readwrite #" ];
    #     password = "12345";
    #   };
    #   users.homeassistant = {
    #     # acl = [ "pattern readwrite #" ];
    #     password = "12345";
    #   };
    #   settings = {
    #     cafile = "/var/lib/acme/mqtt/fullchain.pem";
    #     certfile = "/var/lib/acme/mqtt/cert.pem";
    #     keyfile = "/var/lib/acme/mqtt/key.pem";
    #     require_certificate = true;
    #     # use_identity_as_username = true;
    #     tls_version = "tlsv1.2";
    #   };
    # },
  ];

  services.mosquitto.bridges.openwb = {
      addresses = [
        { address = "192.168.1.253"; port = 1883; }
      ];
      topics = [ "openWB/# both 2"];
      settings = {
        start_type = "automatic";
        local_clientid = "openwb.mosquitto";
        try_private = false;
        cleansession = true;
      };
    };

  services.telegraf = {
    enable = true;
    extraConfig = {
      outputs.influxdb_v2 = {
        urls = [ "https://influxdb.${secrets.domain}" ];
        bucket = "openwb";
        token = secrets.influxdb.telegraf.token;
        organization = secrets.influxdb.organization;
      };

      inputs.mqtt_consumer = {
        servers = [ "tcp://127.0.0.1:1883" ];
        topics = [  "openWB/global/#" "openWB/evu/#" "openWB/lp/#" "openWB/pv/#"];
        client_id = "openwb-telegraf";
        data_format = "value";
        data_type = "float";
      };
    };
  };

  # networking.nat.enable = true;
  # networking.nat.internalInterfaces = ["ve-homeassistant"];
  # networking.nat.externalInterface = "enp0s25";
  # networking.networkmanager.unmanaged = [ "interface-name:ve-homeassistant" ];

  virtualisation.oci-containers = {
    backend = "podman";
    # autoPrune = {
    #   enable = true;
    # };
    containers.homeassistant = {
      volumes = [ "/home/woodhouse/hass:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2022.9";
      extraOptions = [ 
        "--privileged"
        "--network=host"
      ];
    };

    containers.node-red = {
      volumes = [ "/home/woodhouse/node-red:/data" ];
      environment.TZ = "Europe/Berlin";
      image = "nodered/node-red:2.2.3";
      ports = [ "1880:1880" ];
      extraOptions = [ 
        "--network=host"
      ];
    };

    containers.grafana = {
      volumes = [ "/home/woodhouse/grafana:/var/lib/grafana" ];
      environment.TZ = "Europe/Berlin";
      environment.GF_SERVER_DOMAIN = "grafana.${secrets.domain}";
      image = "grafana/grafana-oss:9.1.5";
      ports = [ "3000:3000" ];
      extraOptions = [ 
        "--network=host"
        "--user=1000" # https://grafana.com/docs/grafana/v9.0/setup-grafana/configure-docker/#run-grafana-container-using-bind-mounts
      ];
    };

    containers.influxdb= {
      volumes = [ "/home/woodhouse/influxdb/data:/var/lib/influxdb2" "/home/woodhouse/influxdb/config:/etc/influxdb2"];
      environment = {
        TZ = "Europe/Berlin";
        DOCKER_INFLUXDB_INIT_MODE = "setup";
        DOCKER_INFLUXDB_INIT_USERNAME = secrets.influxdb.username;
        DOCKER_INFLUXDB_INIT_PASSWORD = secrets.influxdb.password;
        DOCKER_INFLUXDB_INIT_ORG = "home";
        DOCKER_INFLUXDB_INIT_BUCKET = "default";
      };
      image = "influxdb:2.4.0";
      ports = [ "8086:8086" ];
      extraOptions = [ 
        "--network=host"
      ];
    };
  };

  services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      # other Nginx options
      virtualHosts."home.${secrets.domain}" =  {
        useACMEHost = "home.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true; # needed if you need to use WebSocket
          # extraConfig =
          #   # required when the target is also TLS server with multiple hosts
          #   "proxy_ssl_server_name on;" +
          #   # required when the server wants to use HTTP Authentication
          #   "proxy_pass_header Authorization;"
          #   ;
        };
      };

      # systemctl status acme-node-red.${secrets.domain}.service
      virtualHosts."node-red.${secrets.domain}" =  {
        useACMEHost = "node-red.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:1880";
          proxyWebsockets = true;
        };
      };

      virtualHosts."influxdb.${secrets.domain}" =  {
        useACMEHost = "influxdb.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8086";
          proxyWebsockets = true;
        };
      };

      virtualHosts."grafana.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
  };

  security.acme = {
    acceptTerms = true;
    email = "aliasgram@gmail.com";
  };

  security.acme.certs."home.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."node-red.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."influxdb.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."grafana.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      config = "sudo vim /etc/nixos/configuration.nix";
      upgrade = "sudo nixos-rebuild switch --upgrade";
    };

    ohMyZsh = {
      enable = true;
      customPkgs = with pkgs; [ spaceship-prompt ];
      theme = "spaceship";
      plugins = [ "git" "z" ];
    };
  };

  services.tlp = {
    enable = true;
    extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      CPU_MAX_PERF_ON_AC=30
      CPU_MAX_PERF_ON_BAT=30
    '';
  };

  nix.autoOptimiseStore = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  system.autoUpgrade.enable = false;

  services.logind.lidSwitch = "ignore";

  networking.firewall.allowedTCPPorts = [ 80 443 8123 6053 1883 8883 8080 8880 8843 8443 3000 8086 ];
  networking.firewall.allowedUDPPorts = [ 5353 3478 10001 ];

  environment.systemPackages = with pkgs; [ vim zsh git];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

