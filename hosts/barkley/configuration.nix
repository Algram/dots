# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages-rt;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = secrets.hostname;

  nixpkgs.config.permittedInsecurePackages = [ "libsoup-2.74.3" ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # https://github.com/music-assistant/support/issues/4158
  # networking.extraHosts = ''
  #   0.0.0.0 apresolve.spotify.com
  #   :: apresolve.spotify.com
  # '';

  # systemd.user.services.snapclient-local = {
  #   wantedBy = [
  #     "pipewire.service"
  #   ];
  #   after = [
  #     "pipewire.service"
  #   ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID office";
  #   };
  # };

  services.fwupd.enable = true;

  # Start WirePlumber (with PipeWire) at boot.
  # systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    linger = true;
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups =
      [ "wheel" "docker" "postgres" "libvirtd" "audio" "bluetooth" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     # ''@reboot systemctl --user start squeezelite-user-bathroom''
  #     # ''@reboot systemctl --user start squeezelite-user-office''
  #     # ''0 1 * * *     root   podman exec --user "$(id -u):$(id -g)" -it influxdb influx backup /home/influxdb/backup/ -t ${secrets.influxdb.admin.token}''
  #     "1 * * * * root systemctl stop podman-neolink.service && sudo systemctl start podman-neolink.service "
  #   ];
  # };

  nixpkgs.config.allowUnfree = true;

  services.unifi.enable = true;
  services.unifi.openFirewall = true;
  services.unifi.unifiPackage = pkgs.unifi;
  services.unifi.mongodbPackage = pkgs.mongodb-ce;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  time.timeZone = "Europe/Berlin";

  services.mosquitto.enable = true;
  services.mosquitto.listeners = [{
    omitPasswordAuth = true;
    settings.allow_anonymous = true;
    acl = [ "topic readwrite #" "pattern readwrite #" ];
    users = { };
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
    addresses = [{
      address = "192.168.1.253";
      port = 1883;
    }];
    topics = [
      "openWB/set/vehicle/template/charge_template/+/chargemode/selected out"
      "openWB/set/vehicle/template/charge_template/+/chargemode/instant_charging/limit/selected out"
      "openWB/set/vehicle/template/charge_template/+/chargemode/instant_charging/limit/soc out"
      "openWB/set/vehicle/template/charge_template/+/chargemode/instant_charging/limit/amount out"
      "openWB/set/vehicle/template/charge_template/+/chargemode/instant_charging/current out"
      "openWB/set/vehicle/template/charge_template/+/chargemode/pv_charging/min_current out"

      "openWB/chargepoint/1/get/connected_vehicle/config in"
      "openWB/chargepoint/1/get/connected_vehicle/info in"
      "openWB/chargepoint/1/get/# in"
      "openWB/chargepoint/1/config in"
      "openWB/chargepoint/1/get/+ in"
      "openWB/chargepoint/1/get/connected_vehicle/soc in"
      "openWB/set/chargepoint/1/config/ev out"

      "openWB/chargepoint/2/get/connected_vehicle/config in"
      "openWB/chargepoint/2/get/connected_vehicle/info in"
      "openWB/chargepoint/2/get/# in"
      "openWB/chargepoint/2/config in"
      "openWB/chargepoint/2/get/+ in"
      "openWB/chargepoint/2/get/connected_vehicle/soc in"
      "openWB/set/chargepoint/2/config/ev out"
    ];
    settings = {
      start_type = "automatic";
      local_clientid = "openwb.mosquitto";
      # try_private = true;
      # cleansession = true; # Can lead to messages being retained more often
    };
  };

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = { omit_hostname = true; };
      outputs.influxdb_v2 = [{
        urls = [ "https://influxdb.${secrets.domain}" ];
        bucket = "energy";
        token = secrets.influxdb.telegraf.energy.token;
        organization = secrets.influxdb.organization;
        name_override = "energy";
        namepass = [ "energy*" "pv*" ];
      }
      # {
      #   urls = [ "https://influxdb.${secrets.domain}" ];
      #   bucket = "openwb";
      #   namedrop = ["energy*" "pv*"];
      #   token = secrets.influxdb.telegraf.token;
      #   organization = secrets.influxdb.organization;

      # }
        ];

      inputs.mqtt_consumer = [{
        servers = [ "tcp://127.0.0.1:1883" ];
        topics = [ "energy/#" ];
        client_id = "energy-telegraf";
        data_format = "value";
        name_override = "energy";
        data_type = "float";
        qos = 2;
        persistent_session = true;
      }
      # {
      #   servers = [ "tcp://192.168.1.253:1883" ];
      #   topics = [
      #     "openWB/global/ChargeMode"
      #     "openWB/global/WHouseConsumption"
      #     "openWB/global/WAllChargePoints"
      #     "openWB/global/DailyYieldHausverbrauchKwh"
      #     "openWB/global/DailyYieldAllChargePointsKwh"
      #     "openWB/global/kWhCounterAllChargePoints"
      #     "openWB/global/strLastmanagementActive"
      #   "openWB/evu/#" "openWB/lp/#" "openWB/chargepoint/#" "openWB/bat/#" "openWB/pv/#" "openWB/SmartHome/#"];
      #   # client_id = "openwb-telegraf";
      #   data_format = "value";
      #   data_type = "float";
      #   # qos = 2;
      #   # persistent_session = true;
      # }
        ];

      # inputs.http = [
      #   {
      #     # https://api.forecast.solar/estimate/:lat/:lon/:dec/:az/:kwp
      #     urls = [
      #       "https://api.forecast.solar/estimate/watts/${secrets.forecast_solar.location}?time=utc"
      #     ];
      #     headers = {
      #       accept = "text/csv";
      #       "X-Delimiter" = "|";
      #       "X-Separator" = ";";
      #     };
      #     data_format = "csv";
      #     data_type = "float";
      #     alias = "pvForecastWatts";
      #     name_override = "pvForecastWatts";
      #     interval = "3600s";
      #     csv_header_row_count = 0;
      #     csv_column_names = [ "time" "value" ];
      #     csv_column_types = [ "string" "float" ];
      #     csv_delimiter = ";";
      #     csv_timestamp_column = "time";
      #     csv_timestamp_format = "2006-01-02T15:04:05-07:00";
      #   }
      #   {
      #     urls = [
      #       "https://api.forecast.solar/estimate/watthours/${secrets.forecast_solar.location}?time=utc"
      #     ];
      #     headers = {
      #       accept = "text/csv";
      #       "X-Delimiter" = "|";
      #       "X-Separator" = ";";
      #     };
      #     data_format = "csv";
      #     data_type = "float";
      #     alias = "pvForecastWattHours";
      #     name_override = "pvForecastWattHours";
      #     interval = "3600s";
      #     csv_header_row_count = 0;
      #     csv_column_names = [ "time" "value" ];
      #     csv_column_types = [ "string" "float" ];
      #     csv_delimiter = ";";
      #     csv_timestamp_column = "time";
      #     csv_timestamp_format = "2006-01-02T15:04:05-07:00";
      #   }
      #   {
      #     urls = [
      #       "https://api.forecast.solar/estimate/watthours/day/${secrets.forecast_solar.location}?time=utc"
      #     ];
      #     headers = {
      #       accept = "text/csv";
      #       "X-Delimiter" = "|";
      #       "X-Separator" = ";";
      #     };
      #     data_format = "csv";
      #     data_type = "float";
      #     alias = "pvForecastWattHoursDay";
      #     name_override = "pvForecastWattHoursDay";
      #     interval = "3600s";
      #     csv_header_row_count = 0;
      #     csv_column_names = [ "time" "value" ];
      #     csv_column_types = [ "string" "float" ];
      #     csv_delimiter = ";";
      #     csv_timestamp_column = "time";
      #     csv_timestamp_format = "2006-01-02";
      #   }
      # ];
    };
  };

  services.adguardhome = {
    enable = true;
    port = 3003;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "127.0.0.1:3003";
      };
      dns = {
        upstream_dns = [
          # Example config with quad9
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled =
          false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled =
            false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map (url: {
        enabled = true;
        url = url;
      }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
      ];
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/home/${secrets.username}/hass:/config" ];
      environment = {
        TZ = "Europe/Berlin";

      };

      image = "ghcr.io/home-assistant/home-assistant:2026.1";
      extraOptions = [
        "--privileged"
        "--network=host"
        "--dns=192.168.1.1"
        "--add-host=nextcloud.raphael.sh:192.168.1.152"
      ];
    };

    containers.node-red = {
      volumes = [ "/home/${secrets.username}/node-red:/data" ];
      environment.TZ = "Europe/Berlin";
      image = "nodered/node-red:4.1.0";
      ports = [ "1880:1880" ];
      # Host Network needed for receiving home manager udp multicast
      extraOptions = [ "--network=host" ];
    };

    containers.grafana = {
      volumes = [ "/home/${secrets.username}/grafana:/var/lib/grafana" ];
      environment.TZ = "Europe/Berlin";
      environment.GF_SERVER_DOMAIN = "grafana.${secrets.domain}";
      environment.GF_SECURITY_ALLOW_EMBEDDING = "true";
      environment.GF_AUTH_DISABLE_LOGIN_FORM = "true";
      environment.GF_AUTH_ANONYMOUS_ENABLED = "true";
      environment.GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin";
      image = "grafana/grafana-oss:12.1.1";
      ports = [ "3000:3000" ];
      extraOptions = [
        # "--network=host"
        "--user=1000" # https://grafana.com/docs/grafana/v9.0/setup-grafana/configure-docker/#run-grafana-container-using-bind-mounts
      ];
    };

    containers.influxdb = {
      volumes = [
        "/home/${secrets.username}/influxdb/data:/var/lib/influxdb2"
        "/home/${secrets.username}/influxdb/config:/etc/influxdb2"
        "/home/${secrets.username}/influxdb/backup:/home/influxdb/backup"
      ];
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
      extraOptions = [ "--network=host" ];
    };

    containers.esphome = {
      volumes = [ "/home/${secrets.username}/esphome:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "esphome/esphome:2025.11.0";
      extraOptions = [ "--privileged" "--network=host" ];
    };

    containers.paperless-ngx = {
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
        PAPERLESS_CONSUMER_ENABLE_BARCODES =
          "true"; # enable search for barcodes
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
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.0";
      ports = [ "8000:8000" ];
      extraOptions = [ "--privileged" "--network=host" ];
    };

    # containers.excalidraw = {
    #   image = "excalidraw/excalidraw:latest";
    #   ports = [ "5001:80" ];
    # };

    # containers.nextcloud-aio-mastercontainer = {
    #   volumes = [
    #     "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
    #     "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
    #   ];
    #   environment = { NEXTCLOUD_DATADIR = "/home/barkley/nextcloud-aio"; };
    #   image = "nextcloud/all-in-one:latest";
    #   ports = [ "1080:80" "2080:8080" "2443:8443" ];
    #   extraOptions = [ "--privileged" ];
    # };

    containers.watcharr = {
      volumes = [ "/home/${secrets.username}/watcharr:/data" ];
      image = "ghcr.io/sbondco/watcharr:latest";
      ports = [ "3080:3080" ];
    };

    # containers.frigate = {
    #   volumes = [
    #     "/home/${secrets.username}/frigate/media:/media/frigate"
    #     "/home/${secrets.username}/frigate/config:/config"
    #   ];
    #   image = "ghcr.io/blakeblackshear/frigate:stable";
    #   ports =
    #     [ "8971:8971" "8556:8554" "8555:8555/tcp" "8555:8555/udp" "1984:1984" ];
    #   devices = [ "/dev/dri/renderD128" ];
    #   extraOptions = [ "--privileged" ];
    #   environment = {
    #     FRIGATE_RTSP_PASSWORD = "password";

    #   };
    # };

    # containers.lms = {
    #   volumes = [ "/home/${secrets.username}/lms:/config" ];
    #   image = "lmscommunity/lyrionmusicserver";
    #   ports = [ "9002:9002" "9090:9090" "3483:3483" ];
    #   environment = {
    #     HTTP_PORT = "9002";

    #   };
    #   extraOptions = [ "--network=host" ];
    # };

    #     containers.matter-server = {
    #       volumes = [ "/home/${secrets.username}/matter-server:/data" "/run/dbus:/run/dbus:ro" ];
    #       image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
    #       extraOptions = [
    #         "--security-opt=apparmor=unconfined"
    #         "--network=host"
    #         # ''--sysctl=net.ipv6.conf.all.disable_ipv6=0''
    #         #         ''--sysctl=net.ipv6.conf.all.accept_ra_rt_info_max_plen=64''
    #         # ''--sysctl=net.ipv6.conf.all.accept_ra=1''
    #       ];
    #       cmd = [
    # "--storage-path=/data"
    # "--paa-root-cert-dir=/data/credentials"
    # "--bluetooth-adapter=0"
    # "--log-level=debug"
    #       ];
    #       # entrypoint = "matter-server --storage-path /data --paa-root-cert-dir /data/credentials --bluetooth-adapter 0";
    #     };

    # containers.ser2net = {
    #   volumes = [ "/home/${secrets.username}/ser2net:/data" ];
    #   image = "ghcr.io/jippi/docker-ser2net";
    #   extraOptions = [
    #     "--security-opt=apparmor=unconfined"
    #     "--network=host"
    #   ];
    # };

    # TODO make var lib docker or so persisted
    # containers.otbr = {
    #   image = "openthread/otbr:test";
    #   volumes = [ "/dev/ttyUSB0:/tmp/ttyOTBR" "/home/barkley/otbr/thread:/var/lib/thread" ];
    #   ports = [ "8081:80" "3081:8081"];
    #   # cmd = [
    #   #   "--radio-url spinel+hdlc+uart:///dev/ttyUSB1?uart-baudrate=460800"
    #   # ];
    #   # entrypoint = 
    #   #       ''/usr/sbin/otbr-agent" \
    #   #   --rest-listen-address "::" \
    #   #       -v -s \
    #   #   "spinel+hdlc+uart:///tmp/ttyOTBR?uart-baudrate=460800&uart-init-deassert"''
    #   # ;
    #   # entrypoint = "/usr/sbin/otbr-agent --help";
    #   environment = {
    #     # RADIO_URL = "spinel+hdlc+uart:///tmp/ttyOTBR?uart-baudrate=460800&uart-flow-control";
    #     RADIO_URL = "spinel+hdlc+uart:///tmp/ttyOTBR?uart-baudrate=460800&uart-init-deassert";
    #     # RADIO_URL = "spinel+hdlc+uart:///tmp/ttyOTBR";
    #     # TREL_URL = "trel://enp0s31f6";
    #     # DHCPV6_PD_REF = "0";
    #     # BACKBONE_INTERFACE = "enp0s31f6";        
    #   };
    #   extraOptions = [
    #     ''--sysctl=net.ipv6.conf.all.disable_ipv6=0''
    #     ''--sysctl=net.ipv4.conf.all.forwarding=1''
    #     ''--sysctl=net.ipv6.conf.all.forwarding=1''
    #     # ''--sysctl=net.ipv6.conf.all.accept_ra_rt_info_max_plen=64''
    #     # ''--sysctl=net.ipv6.conf.all.accept_ra=2''
    #     "--privileged"
    #     "--dns=127.0.0.1"
    #     # "--network=host"
    #   ];
    # };

    containers.music-assistant = {
      volumes = [
        "/home/${secrets.username}/music-assistant:/data"
        "/home/${secrets.username}/music-assistant-media:/media"
      ];
      image = "ghcr.io/music-assistant/server:2.8.0b4";
      extraOptions = [
        "--cap-add=DAC_READ_SEARCH"
        "--cap-add=SYS_ADMIN"
        "--security-opt=apparmor=unconfined"
        "--network=host"
      ];
    };

    # containers.neolink = {
    #   volumes =
    #     [ "/home/${secrets.username}/neolink/neolink.toml:/etc/neolink.toml" ];
    #   image = "quantumentangledandy/neolink";
    #   # image = "thirtythreeforty/neolink";
    #   extraOptions = [ "--network=host" "-m=4000m" ];
    #   environment = {
    #     NEO_LINK_PORT = "8599";
    #     NEO_LINK_MODE = "mqtt-rtsp";

    #   };
    # };

    # containers.cloudflare-ddns = {
    #   volumes =
    #     [ "/home/${secrets.username}/cfdyndns/config.json:/config.json" ];
    #   image = "timothyjmiller/cloudflare-ddns:latest";
    #   # image = "thirtythreeforty/neolink";
    #   extraOptions = [ "--network=host" ];
    #   environment = {
    #     PUID = "1000";
    #     PGID = "1000";

    #   };
    # };
  };

  # services.spotifyd = {
  #   enable = true;
  #   settings = {
  #     global = {
  #       username = secrets.spotify.username;
  #       password = secrets.spotify.password;
  #       device_name = "office";
  #       device = "sysdefault:Device";
  #     };
  #   };
  # };

  # services.shairport-sync.enable = true;
  # services.shairport-sync.openFirewall = true;
  # services.shairport-sync.settings = {
  #   general.output_backend = "pa";
  #   pa.sink =
  #     "alsa_output.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.analog-stereo";
  # };

  # user and group
  # users = {
  #   users.shairport = {
  #     description = "Shairport user";
  #     isSystemUser = true;
  #     createHome = true;
  #     home = "/var/lib/shairport-sync";
  #     group = "shairport";
  #     extraGroups = [ "pulse-access" ];
  #   };
  #   groups.shairport = { };
  # };

  # # systemd services
  # systemd.services = {
  #   nqptp = {
  #     description = "Network Precision Time Protocol for Shairport Sync";
  #     wantedBy = [ "multi-user.target" ];
  #     after = [ "network.target" ];
  #     serviceConfig = {
  #       ExecStart = "${pkgs.nqptp}/bin/nqptp";
  #       Restart = "always";
  #       RestartSec = "5s";
  #     };
  #   };
  #   #   shairport-sync-office = {
  #   #     description = "Dining room speakers shairport-sync instance";
  #   #     wantedBy = [ "multi-user.target" ];
  #   #     after = [ "network.target" ];
  #   #     serviceConfig = {
  #   #       User = "shairport";
  #   #       Group = "shairport";
  #   #       ExecStart =
  #   #         "${pkgs.shairport-sync}/bin/shairport-sync -c /etc/office.conf";
  #   #       Restart = "on-failure";
  #   #       RuntimeDirectory = "shairport-sync";
  #   #     };
  #   #   };
  #   #   # outdoor-speakers = {
  #   #   #   description = "Outdoor speakers shairport-sync instance";
  #   #   #   wantedBy = [ "multi-user.target" ];
  #   #   #   after = [ "network.target" "avahi-daemon.service" ];
  #   #   #   serviceConfig = {
  #   #   #     User = "shairport";
  #   #   #     Group = "shairport";
  #   #   #     ExecStart =
  #   #   #       "${pkgs.shairport-sync-airplay2}/bin/shairport-sync -c /etc/outdoor_speakers.conf";
  #   #   #     Restart = "on-failure";
  #   #   #     RuntimeDirectory = "shairport-sync";
  #   #   #   };
  #   #   # };
  # };

  # services.avahi.enable = true;
  # services.avahi.publish.enable = true;
  # services.avahi.publish.userServices = true;

  # # write shairport-sync configs
  # environment.etc."office.conf".text = ''
  #   general =
  #   {
  #     name = "Office";
  #     output_backend = "pa";
  #     # airplay_device_id_offset = 0;
  #     buffer_start_fill = 22050;  # 0.5 seconds
  #     audio_backend_latency_offset_in_seconds = 0.15;
  #   };

  #   pa =
  #   {
  #     sink = "alsa_output.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.analog-stereo";
  #   };
  # '';

  # environment.etc."bathroom.conf".text = ''
  #   general =
  #   {
  #     name = "Bathroom";
  #     output_backend = "pa";
  #     port = 7001;
  #     buffer_start_fill = 22050;  # 0.5 seconds
  #     airplay_device_id_offset = 1;
  #   };

  #   pa =
  #   {
  #     sink = "bluez_sink.88_92_CC_01_77_11.a2dp_sink";
  #   };
  # '';
  # environment.etc."outdoor_speakers.conf".text = ''
  #   general =
  #   {
  #     name = "Outdoor Speakers";
  #     output_backend = "pa";
  #     port = 7001;
  #     airplay_device_id_offset = 1;
  #   };

  #   pa =
  #   {
  #     sink = "alsa_output.usb-Generic_USB_Audio_20210726905926-00.analog-stereo.2";
  #   };
  # '';

  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
  # hardware.pulseaudio.support32Bit = true;

  security.rtkit.enable = true;

  services.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    # systemWide = true;
  };

  # services.pulseaudio.extraConfig =
  #   "\n    load-module module-switch-on-connect\n  ";
  # services.pulseaudio.support32Bit = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # package = pkgs.bluez-alsa;
    # settings.general = { enable = "Source,Sink,Media,Socket"; };
  };

  hardware.bluetooth.settings = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };

  services.pipewire = {
    enable = false;
    # socketActivation = true;
    # audio.enable = true;
    # alsa.enable = true;
    # alsa.support32Bit = true;
    # pulse.enable = true;
    # wireplumber.enable = true;
    # enable = false; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # media-session.enable = false;
    # jack.enable = true;
    # wireplumber.extraConfig."11-bluetooth-policy" = {
    #   "wireplumber.settings" = {
    #     "bluetooth.autoswitch-to-headset-profile" = false;
    #   };
    # };

    # wireplumber.extraConfig.bluetoothEnhancements = {
    #   "monitor.bluez.properties" = {
    #     "bluez5.enable-sbc-xq" = true;
    #     "bluez5.enable-msbc" = true;
    #     "bluez5.enable-hw-volume" = true;
    #     "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" "a2dp_sink" "a2dp_source" ];
    #   };
    # };

    # wireplumber = {
    #   enable = true;
    #   extraConfig = {
    #     "monitor.bluez" = {
    #       properties = {
    #         # Force high-quality A2DP only
    #         "bluez5.enable-sbc-xq" = true;
    #         "bluez5.enable-msbc" = false;
    #         "bluez5.enable-hw-volume" = true;

    #         # Disable headset profiles (break Sony speakers)
    #         "bluez5.enable-hfp" = false;
    #         "bluez5.enable-hsp" = false;
    #       };
    #     };
    #   };
    # };

  };

  # services.pipewire.wireplumber.extraConfig = {
  #   "monitor.bluez" = {
  #     rules = [{
  #       matches = [{ "device.name" = "~bluez_card.*"; }];
  #       actions = {
  #         update-props = {
  #           "bluez5.enable-hfp" = false;
  #           "bluez5.enable-hsp" = false;
  #         };
  #       };
  #     }];
  #   };
  # };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };

  services.redis.servers."paperless-ngx".enable = true;
  services.redis.servers."paperless-ngx".port = 6379;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "nextcloud.${secrets.domain}";
    # hostName = "localhost";
    https = true;
    configureRedis = true;
    datadir = "/mnt/nextcloud";
    maxUploadSize = "16G";

    caching = {
      redis = true;
      memcached = true;
      apcu = true;
    };

    fastcgiTimeout = 300;

    database.createLocally = true;
    config = {
      adminpassFile = "${pkgs.writeText "adminpass" secrets.nextcloud.root}";
      dbtype = "pgsql";
    };

    settings = {
      memcache.local = "\\OCMemcache\\APCu";
      memcache.distributed = "\\OC\\Memcache\\Redis";
      memcache.locking = "\\OCMemcache\\Redis";
      default_phone_region = "DE";
      maintenance_window_start = 2; # 02:00
      dbpersistent = false;
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
        dbindex = 0;
        # password = "secret";
        timeout = 1.5;
      };
      preview_imaginary_url = "https://imaginary.raphael.sh";

      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
      ];

      trusted_domains = [ "nextcloud.raphael.sh" "imaginary.raphael.sh" ];
    };

    phpOptions."opcache.interned_strings_buffer" = "80";
    phpOptions."opcache.memory_consumption" = "512";
    phpOptions."max_chunk_size" = "20971520";
    phpOptions."max_input_time" = "3600";
    phpOptions."upload_max_filesize" = "16G";
    phpOptions."post_max_size" = "16G";
    phpOptions."upload_tmp_dir" = "/home/barkley/nextcloud-upload-temp";

    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "300";
      "pm.start_servers" = "50";
      "pm.min_spare_servers" = "50";
      "pm.max_spare_servers" = "250";
      "pm.max_requests" = "500";
    };
  };

  services.postgresqlBackup = {
    enable = true;

    # Back up only the Nextcloud database
    databases = [ "nextcloud" ];

    # Where backups are stored
    location = "/var/lib/nextcloud/backups";

    # cron schedule for backup to be performed
    startAt = "*-*-* 23:15:00";

    # # Keep backups for N days (optional but smart)
    # retentionDays = 14;
  };

  services.mysql = {
    enable = false;
    package = pkgs.mariadb;
    ensureDatabases = [ "pp" ];
    ensureUsers = [{
      name = "photoprism";
      ensurePermissions = { "pp.*" = "ALL PRIVILEGES"; };
    }];
  };

  # services.photoprism = {
  #   enable = false;
  #   port = 2342;
  #   originalsPath = "/mnt/photoprism/data/raphael/files/phone_upload/Camera";
  #   address = "0.0.0.0";
  #   settings = {
  #     PHOTOPRISM_ADMIN_USER = "admin";
  #     PHOTOPRISM_ADMIN_PASSWORD = "1234";
  #     PHOTOPRISM_DEFAULT_LOCALE = "en";
  #     PHOTOPRISM_DATABASE_DRIVER = "mysql";
  #     PHOTOPRISM_DATABASE_NAME = "pp";
  #     PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
  #     PHOTOPRISM_DATABASE_USER = "photoprism";
  #     PHOTOPRISM_DATABASE_PASSWORD = "1234";
  #     PHOTOPRISM_SITE_URL = "https://photoprism.raphael.sh";
  #     PHOTOPRISM_SITE_TITLE = "My PhotoPrism";
  #     PHOTOPRISM_READ_ONLY = "true";
  #     PHOTOPRISM_INDEX_SCHEDULE = "*/10 * * * *";
  #   };
  # };

  # services.imaginary = {
  #   enable = false;

  #   settings.return-size = true;
  # };

  fileSystems."/mnt/nextcloud" = {
    device = "//192.168.1.150/nextcloud";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts =
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in [
      "${automount_opts},username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"
    ];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  };

  # fileSystems."/mnt/photoprism" = {
  #   device = "//192.168.1.150/nextcloud";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts =
  #       "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #   in [
  #     "${automount_opts},username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},mfsymlinks,file_mode=0555,dir_mode=0555"
  #   ];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  # };

  fileSystems."/mnt/paperless" = {
    device = "192.168.1.150:/mnt/data/paperless";
    fsType = "nfs";
  };

  # services.nginx.virtualHosts."localhost".listen = [{
  #   addr = "127.0.0.1";
  #   port = 8083;
  # }];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."nextcloud.${secrets.domain}" = {
      forceSSL = true;
      useACMEHost = "grafana.${secrets.domain}";
    };

    # virtualHosts."nextcloud.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   # acmeRoot = null;
    #   addSSL = true;
    #   # directs traffic to the appropriate port for nextcloud
    #   locations."/" = {
    #     proxyPass = "http://localhost:80";
    #     proxyWebsockets = true;
    #   };
    # };

    # virtualHosts."nextcloud.${secrets.domain}" = {
    #   locations."/".proxyPass = "http://127.0.0.1:8084";
    #   extraConfig = ''
    #     allow 192.168.0.1/24;
    #     deny all;
    #   '';
    # };

    # virtualHosts."nextcloud-external.${secrets.domain}" = {
    #   forceSSL = true;
    #   useACMEHost = "grafana.${secrets.domain}";
    # };

    # virtualHosts."music.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:9092";
    #     proxyWebsockets = true;
    #   };
    # };

    # virtualHosts."z2m.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:3081";
    #     proxyWebsockets = true;
    #   };
    # };

    # virtualHosts."excalidraw.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:5001";
    #     proxyWebsockets = true;
    #   };
    # };

    virtualHosts."esphome.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
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

    # virtualHosts."3d.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://192.168.1.151:80";
    #     proxyWebsockets = true;
    #   };
    # };

    # ----------------

    # other Nginx options
    virtualHosts."home.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
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

    virtualHosts."node-red.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:1880";
        proxyWebsockets = true;
      };
    };

    virtualHosts."music.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8095";
        proxyWebsockets = true;
      };
    };

    virtualHosts."unifi.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://127.0.0.1:8443";
        proxyWebsockets = true;
      };
    };

    virtualHosts."nas.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://192.168.1.150:443";
        proxyWebsockets = true;
      };
    };

    virtualHosts."wallbox.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.1.253:80";
        proxyWebsockets = true;
      };
    };

    virtualHosts."paperless.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        # proxyPass = "http://127.0.0.1:28981";
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
      };
    };

    # virtualHosts."neolink.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:8599";
    #     proxyWebsockets = true;
    #   };
    # };

    virtualHosts."influxdb.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8086";
        proxyWebsockets = true;
      };
    };

    virtualHosts."grafana.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };

    # virtualHosts."imaginary.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:8088";
    #     proxyWebsockets = true;
    #   };
    # };

    # virtualHosts."photoprism.${secrets.domain}" = {
    #   useACMEHost = "grafana.${secrets.domain}";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:2342";
    #     proxyWebsockets = true;
    #   };
    # };

    virtualHosts."watcharr.${secrets.domain}" = {
      useACMEHost = "grafana.${secrets.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3080";
        proxyWebsockets = true;
      };
    };

  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aliasgram@gmail.com";
  };

  # hardware.pulseaudio.enable = false;
  # hardware.bluetooth.enable = false; # enables support for Bluetooth
  # hardware.bluetooth.powerOnBoot = true;
  # hardware.bluetooth.settings = {
  #   General = {
  #     Enable = "Source,Sink,Media,Socket";
  #   };
  # };

  services.blueman.enable = true;

  security.acme.certs."grafana.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env"
      secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env"
      secrets.acme.cloudflare.credentials;
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
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_MAX_PERF_ON_AC = 30;
      CPU_MAX_PERF_ON_BAT = 30;
    };
  };

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.autoUpgrade.enable = false;

  services.dbus.enable = true;

  networking.firewall.enable = false;

  # 9522 for SMA Home Manager multicast messages "1080:80" "2080:8080" "2443:8443"
  networking.firewall.allowedTCPPorts = [
    8554
    8599
    5900
    80
    443
    8123
    6053
    1883
    8883
    8080
    8880
    8843
    8443
    3000
    8086
    9522
    6052
    28981
    5201
    8088
    8000
    1080
    2080
    2443
    8081
    8095
    3483
    9000
    9090
    8097
    8098
    5580
    3081
  ]; # 6052 for esphome, 28981 for paperless, 8088 for imaginary
  networking.firewall.allowedUDPPorts = [
    5353
    3478
    10001
    9522
    5201
    4003
    8095
    3483
    9000
    9090
    8097
    8098
  ]; # 4003 govee lan local

  environment.systemPackages = with pkgs; [
    php
    rrsync
    vim
    zsh
    git
    netavark
    powertop
    htop
    # esphome
    samba
    # zxing
    # zxing-cpp
    # python311Packages.zxing-cpp
    ustreamer
    # quickemu
    # virt-manager
    bluez
    bluetuith
    alsa-utils
    bluez-alsa
    spotifyd
    sendspin-cli
    # shairport-sync
  ]; # netavark needed for podman at the moment

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  #   networking.defaultGateway = "192.168.1.1";
  # networking.bridges.br0.interfaces = ["enp0s31f6"];
  # networking.interfaces.br0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [{
  #     "address" = "192.168.1.152";
  #     "prefixLength" = 24;
  #   }];
  # };
}

