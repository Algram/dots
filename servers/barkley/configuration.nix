# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  master = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/9b295ab713858412589e61c1f7c017e29699da0f.tar.gz";
    sha256 = "sha256:062g6fknd07yd9lg5nl1qps9gnwkqsz6wwri45js0ss35cnf9rxq";
  };

  paperless-be = pkgs.paperless-ngx.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) name;
    version = "4.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "paperless-ngx";
      repo = "paperless-ngx";
      rev = "27772257a8f669d575e0176c7a9af2f98395c9d6";
      sha256 = "sha256-5zKFAbqSh8pdUGKx75sODOQr1lqD9gOi4T0e0Xnn6eE=";
    };
  });

  # master = pkgs.fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs";
  #   rev = "master";
  #   sha256 = "sha256-CoYTX9hgxLo72YdMoa0sEywg4kybHbFsypHk2rCM6tM=";
  # };
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${master}/nixos/modules/services/misc/paperless.nix"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = secrets.hostname;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fwupd.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  services.cron = {
    enable = false;
    systemCronJobs = [
      ''0 1 * * *     root   podman exec --user "$(id -u):$(id -g)" -it influxdb influx backup /home/influxdb/backup/ -t ${secrets.influxdb.admin.token}''
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services.unifi.enable = false;
  services.unifi.openPorts = false;
  services.unifi.unifiPackage = pkgs.unifi;
  # services.unifi.mongodbPackage = pkgs.mongodb-6_0;

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
        cleansession = true; # Can lead to messages being retained more often
      };
    };

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        omit_hostname = true;
      };
      outputs.influxdb_v2 = [
        {
          urls = [ "https://influxdb.${secrets.domain}" ];
          bucket = "energy";
          token = secrets.influxdb.telegraf.energy.token;
          organization = secrets.influxdb.organization;
          name_override = "energy";
          namepass = ["energy*" "pv*"];
        }
        {
          urls = [ "https://influxdb.${secrets.domain}" ];
          bucket = "openwb";
          namedrop = ["energy*" "pv*"];
          token = secrets.influxdb.telegraf.token;
          organization = secrets.influxdb.organization;

        }
      ];

      inputs.mqtt_consumer = [
        {
          servers = [ "tcp://127.0.0.1:1883" ];
          topics = [  "energy/#"];
          client_id = "energy-telegraf";
          data_format = "value";
          name_override = "energy";
          data_type = "float";
          qos = 2;
          persistent_session = true;
        }
        {
          servers = [ "tcp://127.0.0.1:1883" ];
          topics = [
            "openWB/global/ChargeMode"
            "openWB/global/WHouseConsumption"
            "openWB/global/WAllChargePoints"
            "openWB/global/DailyYieldHausverbrauchKwh"
            "openWB/global/DailyYieldAllChargePointsKwh"
            "openWB/global/kWhCounterAllChargePoints"
            "openWB/global/strLastmanagementActive"
          "openWB/evu/#" "openWB/lp/#" "openWB/pv/#" "openWB/SmartHome/#"];
          # client_id = "openwb-telegraf";
          data_format = "value";
          data_type = "float";
          # qos = 2;
          # persistent_session = true;
        }
      ];

      inputs.http = [
        {
          # https://api.forecast.solar/estimate/:lat/:lon/:dec/:az/:kwp
          urls = ["https://api.forecast.solar/estimate/watts/${secrets.forecast_solar.location}?time=utc"];
          headers = {
            accept = "text/csv";
            "X-Delimiter" = "|";
            "X-Separator" = ";";
          };
          data_format = "csv";
          data_type = "float";
          alias = "pvForecastWatts";
          name_override = "pvForecastWatts";
          interval = "3600s";
          csv_header_row_count = 0;
          csv_column_names = ["time" "value"];
          csv_column_types = ["string" "float"];
          csv_delimiter = ";";
          csv_timestamp_column = "time";
          csv_timestamp_format = "2006-01-02T15:04:05-07:00";
        }
        {
          urls = ["https://api.forecast.solar/estimate/watthours/${secrets.forecast_solar.location}?time=utc"];
          headers = {
            accept = "text/csv";
            "X-Delimiter" = "|";
            "X-Separator" = ";";
          };
          data_format = "csv";
          data_type = "float";
          alias = "pvForecastWattHours";
          name_override = "pvForecastWattHours";
          interval = "3600s";
          csv_header_row_count = 0;
          csv_column_names = ["time" "value"];
          csv_column_types = ["string" "float"];
          csv_delimiter = ";";
          csv_timestamp_column = "time";
          csv_timestamp_format = "2006-01-02T15:04:05-07:00";
        }
        {
          urls = ["https://api.forecast.solar/estimate/watthours/day/${secrets.forecast_solar.location}?time=utc"];
          headers = {
            accept = "text/csv";
            "X-Delimiter" = "|";
            "X-Separator" = ";";
          };
          data_format = "csv";
          data_type = "float";
          alias = "pvForecastWattHoursDay";
          name_override = "pvForecastWattHoursDay";
          interval = "3600s";
          csv_header_row_count = 0;
          csv_column_names = ["time" "value"];
          csv_column_types = ["string" "float"];
          csv_delimiter = ";";
          csv_timestamp_column = "time";
          csv_timestamp_format = "2006-01-02";
        }
      ];
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
      volumes = [ "/home/${secrets.username}/hass:/config" "/dev/serial/by-id:/dev/serial/by-id"];
      # devices = [ "/dev/ttyUSB0:/dev/ttyUSB0" "/dev/ttyUSB1:/dev/ttyUSB1"];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2023.8.1";
      extraOptions = [ 
        "--privileged"
        "--network=host"
      ];
    };

    containers.node-red = {
      volumes = [ "/home/${secrets.username}/node-red:/data" ];
      environment.TZ = "Europe/Berlin";
      image = "nodered/node-red:3.0.2";
      ports = [ "1880:1880" ];
      extraOptions = [ 
        "--network=host"
      ];
    };

    containers.grafana = {
      volumes = [ "/home/${secrets.username}/grafana:/var/lib/grafana" ];
      environment.TZ = "Europe/Berlin";
      environment.GF_SERVER_DOMAIN = "grafana.${secrets.domain}";
      environment.GF_SECURITY_ALLOW_EMBEDDING = "true";
      environment.GF_AUTH_DISABLE_LOGIN_FORM = "true";
      environment.GF_AUTH_ANONYMOUS_ENABLED = "true";
      environment.GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin";
      image = "grafana/grafana-oss:10.0.3";
      ports = [ "3000:3000" ];
      extraOptions = [ 
        "--network=host"
        "--user=1000" # https://grafana.com/docs/grafana/v9.0/setup-grafana/configure-docker/#run-grafana-container-using-bind-mounts
      ];
    };

    containers.influxdb= {
      volumes = [ "/home/${secrets.username}/influxdb/data:/var/lib/influxdb2" "/home/${secrets.username}/influxdb/config:/etc/influxdb2" "/home/${secrets.username}/influxdb/backup:/home/influxdb/backup"];
      environment = {
        TZ = "Europe/Berlin";
        DOCKER_INFLUXDB_INIT_MODE = "setup";
        DOCKER_INFLUXDB_INIT_USERNAME = secrets.influxdb.username;
        DOCKER_INFLUXDB_INIT_PASSWORD = secrets.influxdb.password;
        DOCKER_INFLUXDB_INIT_ORG = "home";
        DOCKER_INFLUXDB_INIT_BUCKET = "default";
      };
      image = "influxdb:2.7.1";
      ports = [ "8086:8086" ];
      extraOptions = [ 
        "--network=host"
      ];
    };

    # containers.esphome = {
    #   volumes = [ "/home/${secrets.username}/esphome:/config" ];
    #   environment.TZ = "Europe/Berlin";
    #   image = "esphome/esphome:latest";
    #   extraOptions = [
    #     "--privileged"
    #     "--network=host"
    #   ];
    # };

    containers.paperless-ngx= {
      volumes = [
        "/mnt/paperless/data:/usr/src/paperless/data"
        "/mnt/paperless/media:/usr/src/paperless/media"
        "/mnt/paperless/export:/usr/src/paperless/export"
        "/mnt/paperless/consume:/usr/src/paperless/consume"
      ];
      environment = {
        PAPERLESS_TIME_ZONE = "Europe/Berlin";
        PAPERLESS_REDIS = "redis://127.0.0.1:6379";
        PAPERLESS_CONSUMER_POLLING = "10";
        PAPERLESS_CONSUMER_POLLING_RETRY_COUNT = "30";
        PAPERLESS_CONSUMER_ENABLE_BARCODES = "true"; # enable search for barcodes
        PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = "true";
        PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
        PAPERLESS_CONSUMER_RECURSIVE = "true";
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = "true";
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
        USERMAP_UID = "315";
        USERMAP_GID = "315";
        PAPERLESS_URL = "https://paperless.${secrets.domain}"; 
      };
      image = "ghcr.io/paperless-ngx/paperless-ngx:dev";
      ports = [ "8000:8000" ];
      extraOptions = [ 
        "--network=host"
      ];
    };
  };

  services.redis.servers."paperless-ngx-redis".enable = true;
  services.redis.servers."paperless-ngx-redis".port = 6379;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.${secrets.domain}";
    https = true;
    configureRedis = true;
    datadir = "/mnt/nextcloud";

    database.createLocally = true;
    config = {
      adminpassFile = "${pkgs.writeText "adminpass" secrets.nextcloud.root}";
      dbtype = "pgsql";
    };

    phpOptions."opcache.interned_strings_buffer" = "24";
  };

  fileSystems."/mnt/nextcloud" = {
    device = "//192.168.1.150/nextcloud";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  };

  fileSystems."/mnt/paperless" = {
    device = "192.168.1.150:/mnt/data/paperless";
    fsType = "nfs";
  };

  fileSystems."/mnt/paperless-consume" = {
    device = "//192.168.1.150/paperless-consume";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},username=${secrets.paperless.samba.username},password=${secrets.paperless.samba.password},uid=315,gid=315"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  };

  disabledModules = [ "services/misc/paperless.nix" ];

  services.paperless = {
    enable = false;
    # package = paperless-be;
    dataDir = "/mnt/paperless";
    extraConfig = {
      PAPERLESS_CONSUMER_POLLING = 10;
      PAPERLESS_CONSUMER_POLLING_RETRY_COUNT = 30;
      PAPERLESS_CONSUMER_ENABLE_BARCODES = true; # enable search for barcodes
      PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
      PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
    };
    # consumptionDir = "/mnt/paperless-consume";
    # address = "paperless.${secrets.domain}";
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

      virtualHosts."unifi.${secrets.domain}" =  {
        useACMEHost = "unifi.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://127.0.0.1:8443";
          proxyWebsockets = true;
        };
      };

      virtualHosts."esphome.${secrets.domain}" =  {
        useACMEHost = "esphome.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:6052";
          proxyWebsockets = true;
          # extraConfig = ''
          #   proxy_set_header Host $host;
          #   proxy_set_header X-Real-IP $remote_addr;
          #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #   proxy_set_header X-Forwarded-Proto $scheme;
          #   proxy_ssl_name $host;
          #   proxy_ssl_server_name on;
          # '';
        };
      };

      virtualHosts."nas.${secrets.domain}" =  {
        useACMEHost = "nas.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://192.168.1.150:443";
          proxyWebsockets = true;
        };
      };

      virtualHosts."nextcloud.${secrets.domain}" =  {
        forceSSL = true;
        useACMEHost = "nextcloud.${secrets.domain}";
      };

      virtualHosts."paperless.${secrets.domain}" =  {
        useACMEHost = "paperless.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          # proxyPass = "http://127.0.0.1:28981";
          proxyPass = "http://127.0.0.1:8000";
          proxyWebsockets = true;
        };
      };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aliasgram@gmail.com";
  };

  security.acme.certs."nas.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."nextcloud.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."paperless.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
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

  security.acme.certs."unifi.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."esphome.${secrets.domain}" = {
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

  # 9522 for SMA Home Manager multicast messages
  networking.firewall.allowedTCPPorts = [ 80 443 8123 6053 1883 8883 8080 8880 8843 8443 3000 8086 9522 6052 28981 5201]; # 6052 for esphome, 28981 for paperless
  networking.firewall.allowedUDPPorts = [ 5353 3478 10001 9522 5201 ];

  environment.systemPackages = with pkgs; [ rrsync  vim zsh git netavark powertop htop esphome samba zxing zxing-cpp python311Packages.zxing_cpp ]; # netavark needed for podman at the moment

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

