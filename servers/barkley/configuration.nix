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

  # services.squeezelite.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = secrets.hostname;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

    systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.152 --hostID office";
    };
  };

  services.fwupd.enable = true;


  # Start WirePlumber (with PipeWire) at boot.
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  users.defaultUserShell = pkgs.zsh;
  users.users.${secrets.username} = {
    linger = true;
    isNormalUser = true;
    home = "/home/${secrets.username}";
    extraGroups = [ "wheel" "docker" "postgres" "libvirtd" "audio" ];
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      # ''0 1 * * *     root   podman exec --user "$(id -u):$(id -g)" -it influxdb influx backup /home/influxdb/backup/ -t ${secrets.influxdb.admin.token}''
      ''1 * * * * root systemctl stop podman-neolink.service && sudo systemctl start podman-neolink.service ''
    ];
  };

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
      topics = [
        "openWB/set/vehicle/template/charge_template/+/chargemode/selected out"

        "openWB/chargepoint/1/get/connected_vehicle/config in"
        "openWB/chargepoint/1/get/connected_vehicle/info in"
        "openWB/chargepoint/1/get/# in"
        "openWB/chargepoint/1/config in"
        "openWB/chargepoint/1/get/+ in"
        "openWB/chargepoint/1/get/connected_vehicle/soc in"

        "openWB/chargepoint/2/get/connected_vehicle/config in"
        "openWB/chargepoint/2/get/connected_vehicle/info in"
        "openWB/chargepoint/2/get/# in"
        "openWB/chargepoint/2/config in"
        "openWB/chargepoint/2/get/+ in"
        "openWB/chargepoint/2/get/connected_vehicle/soc in"
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
        # {
        #   urls = [ "https://influxdb.${secrets.domain}" ];
        #   bucket = "openwb";
        #   namedrop = ["energy*" "pv*"];
        #   token = secrets.influxdb.telegraf.token;
        #   organization = secrets.influxdb.organization;

        # }
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
      volumes = [ 
        "/home/${secrets.username}/hass:/config"
        # "/dev/serial/by-id:/dev/serial/by-id"
      ];
      # devices = [ "/dev/ttyUSB0:/dev/ttyUSB0" "/dev/ttyUSB1:/dev/ttyUSB1"];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2025.1";
      extraOptions = [ 
        "--privileged"
        "--network=host"
      ];
    };

    containers.node-red = {
      volumes = [ "/home/${secrets.username}/node-red:/data" ];
      environment.TZ = "Europe/Berlin";
      image = "nodered/node-red:3.1.3";
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
      image = "grafana/grafana-oss:10.2.3";
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

    containers.esphome = {
      volumes = [ "/home/${secrets.username}/esphome:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "esphome/esphome:2024.5";
      extraOptions = [
        "--privileged"
        "--network=host"
      ];
    };

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
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.11.3";
      ports = [ "8000:8000" ];
      extraOptions = [ 
        "--privileged"
        "--network=host"
      ];
    };

    containers.excalidraw = {
      image = "excalidraw/excalidraw:latest";
      ports = [ "5000:80" ];
    };

    containers.nextcloud-aio-mastercontainer = {
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
      ];
      environment = {
        NEXTCLOUD_DATADIR = "/home/barkley/nextcloud-aio";
      };
      image = "nextcloud/all-in-one:latest";
      ports = [ "1080:80" "2080:8080" "2443:8443"];
      extraOptions = [ 
        "--privileged"
        # "--network=host"
      ];
    };

    containers.watcharr = {
      volumes = [ "/home/${secrets.username}/watcharr:/data" ];
      image = "ghcr.io/sbondco/watcharr:latest";
      ports = [ "3080:3080" ];
    };

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

    # containers.z2m = {
    #   volumes = [ "/home/${secrets.username}/z2m:/app/data" "/run/udev:/run/udev:ro" ];
    #   image = "koenkk/zigbee2mqtt";
    #   ports = [ "3081:8080" ];
    # };

    
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
      volumes = [ "/home/${secrets.username}/music-assistant:/data" ];
      image = "ghcr.io/music-assistant/server:2.4.0b20";
      extraOptions = [
        "--cap-add=DAC_READ_SEARCH"
        "--cap-add=SYS_ADMIN"
        "--security-opt=apparmor=unconfined"
        "--network=host"
      ];
    };

    containers.neolink = {
      # volumes = [ "/home/${secrets.username}/music-assistant:/data" ];
      volumes = [ "/home/${secrets.username}/neolink/neolink.toml:/etc/neolink.toml" ];
      image = "quantumentangledandy/neolink";
      # restartPolicy = "always";
      extraOptions = [
        "--network=host"
        "-m=2000m"
        # "--restart=always"
      ];
      # ports = [ "8554:8554"];
    };
  };

  # /usr/sbin/otbr-agent --rest-listen-address "::" -v -s "spinel+hdlc+uart:///tmp/ttyOTBR?uart-baudrate=460800&uart-init-deassert"

  # For Linux and without a web server or reverse proxy (like Apache, Nginx, Caddy, Cloudflare Tunnel and else) already in place:
# sudo docker run \
# --init \
# --sig-proxy=false \
# --name nextcloud-aio-mastercontainer \
# --restart always \
# --publish 80:80 \
# --publish 8080:8080 \
# --publish 8443:8443 \
# --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
# --volume /var/run/docker.sock:/var/run/docker.sock:ro \
# nextcloud/all-in-one:latest

  # sound.enable = true;
  # hardware = {

  #   # Replaced by pipewire
  #   # Pulseaudio needed for PS4 bluetooth controller
  #   pulseaudio.enable = true;
  #   pulseaudio.systemWide = true;
  #   pulseaudio.support32Bit = true;
  # };

  services.pipewire = {
    enable = true;
    socketActivation = false;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };


    # nixpkgs.config.pulseaudio = true;
  # services.squeezelite.enable = true;
  # services.squeezelite.pulseAudio = true;

  

  services.redis.servers."paperless-ngx".enable = true;
  services.redis.servers."paperless-ngx".port = 6379;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.${secrets.domain}";
    https = true;
    configureRedis = true;
    datadir = "/mnt/nextcloud";
    maxUploadSize = "16G";

    # extraApps = {
    #   inherit (config.services.nextcloud.package.packages.apps) files_retention;
    # };

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
      memcache.local = "\\OC\Memcache\\APCu";
      memcache.distributed = "\\OC\\Memcache\\Redis";
      memcache.locking = "\\OC\Memcache\\Redis";
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
      # enabledPreviewProviders = [
      #   "OC\\Preview\\MP3"
      #   "OC\\Preview\\TXT"
      #   "OC\\Preview\\MarkDown"
      #   "OC\\Preview\\OpenDocument"
      #   "OC\\Preview\\Krita"
      #   # "OC\\Preview\\Imaginary"
      # ];

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

          trusted_domains = [
        "nextcloud.raphael.sh"
        "imaginary.raphael.sh"
      ];
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

  services.mysql = {
    enable = true;
    # dataDir = "/data/mysql";
    package = pkgs.mariadb;
    ensureDatabases = [ "pp" ];
    ensureUsers = [ {
      name = "photoprism";
      ensurePermissions = {
        "pp.*" = "ALL PRIVILEGES";
      };
    } ];
  };

  services.photoprism = {
    enable = true;
    port = 2342;
    originalsPath = "/mnt/photoprism/data/raphael/files/phone_upload/Camera";
    address = "0.0.0.0";
    settings = {
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_ADMIN_PASSWORD = "1234";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "pp";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_DATABASE_PASSWORD = "1234";
      PHOTOPRISM_SITE_URL = "https://photoprism.raphael.sh";
      PHOTOPRISM_SITE_TITLE = "My PhotoPrism";
      PHOTOPRISM_READ_ONLY = "true";
      PHOTOPRISM_INDEX_SCHEDULE = "*/10 * * * *";
    };
  };

  services.imaginary = {
    enable = false;

    settings.return-size = true;
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

  fileSystems."/mnt/photoprism" = {
    device = "//192.168.1.150/nextcloud";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},mfsymlinks,file_mode=0555,dir_mode=0555"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
    # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  };

  # fileSystems."/mnt/paperless" = {
  #   device = "//192.168.1.150/paperless";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #   in ["${automount_opts},username=${secrets.paperless.samba.username},password=${secrets.paperless.samba.password},uid=315,gid=315,mfsymlinks,file_mode=0770,dir_mode=0770"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  # };

  fileSystems."/mnt/paperless" = {
    device = "192.168.1.150:/mnt/data/paperless";
    fsType = "nfs";
  };

  # fileSystems."/mnt/paperless-consume" = {
  #   device = "//192.168.1.150/paperless-consume";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #   in ["${automount_opts},username=${secrets.paperless.samba.username},password=${secrets.paperless.samba.password},uid=315,gid=315"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  # };

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

      # systemctl status acme-node-red.${secrets.domain}.service
      virtualHosts."node-red.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:1880";
          proxyWebsockets = true;
        };
      };

      virtualHosts."music.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8095";
          proxyWebsockets = true;
        };
      };

      virtualHosts."imaginary.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8088";
          proxyWebsockets = true;
        };
      };

      virtualHosts."photoprism.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2342";
          proxyWebsockets = true;
        };
      };

      virtualHosts."watcharr.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3080";
          proxyWebsockets = true;
        };
      };

      virtualHosts."z2m.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3081";
          proxyWebsockets = true;
        };
      };

      virtualHosts."neolink.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8554";
          proxyWebsockets = true;
        };
      };

      virtualHosts."influxdb.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
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

      virtualHosts."excalidraw.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5000";
          proxyWebsockets = true;
        };
      };

      virtualHosts."unifi.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://127.0.0.1:8443";
          proxyWebsockets = true;
        };
      };

      virtualHosts."esphome.${secrets.domain}" =  {
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

      virtualHosts."nas.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://192.168.1.150:443";
          proxyWebsockets = true;
        };
      };

      virtualHosts."3d.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.151:80";
          proxyWebsockets = true;
        };
      };

      virtualHosts."wallbox.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.253:80";
          proxyWebsockets = true;
        };
      };

      virtualHosts."nextcloud.${secrets.domain}" =  {
        forceSSL = true;
        useACMEHost = "grafana.${secrets.domain}";
      };

      virtualHosts."paperless.${secrets.domain}" =  {
        useACMEHost = "grafana.${secrets.domain}";
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

      hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;

  # security.acme.certs."nas.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."3d.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };
  
  # security.acme.certs."wallbox.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."nextcloud.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."paperless.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."home.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."node-red.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  # security.acme.certs."influxdb.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

  security.acme.certs."grafana.${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  security.acme.certs."${secrets.domain}" = {
    domain = "*.${secrets.domain}";
    group = "nginx";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  };

  # security.acme.certs."esphome.${secrets.domain}" = {
  #   domain = "*.${secrets.domain}";
  #   group = "nginx";
  #   dnsProvider = "cloudflare";
  #   dnsResolver = "1.1.1.1:53";
  #   credentialsFile = builtins.toFile "cloudflare-acme-credentials.env" secrets.acme.cloudflare.credentials;
  # };

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

  services.logind.lidSwitch = "ignore";

  networking.firewall.enable = false;

  # 9522 for SMA Home Manager multicast messages "1080:80" "2080:8080" "2443:8443"
  networking.firewall.allowedTCPPorts = [ 8554 5900 80 443 8123 6053 1883 8883 8080 8880 8843 8443 3000 8086 9522 6052 28981 5201 8088 8000 1080 2080 2443 8081 8095 3483 9000 9090 8097 8098 5580 3081]; # 6052 for esphome, 28981 for paperless, 8088 for imaginary
  networking.firewall.allowedUDPPorts = [ 5353 3478 10001 9522 5201 4003 8095 3483 9000 9090 8097 8098 ]; # 4003 govee lan local

  environment.systemPackages = with pkgs; [ php rrsync  vim zsh git netavark powertop htop esphome samba zxing zxing-cpp python311Packages.zxing_cpp ustreamer quickemu virt-manager ]; # netavark needed for podman at the moment
  # virtualisation.libvirtd.enable = true;
  # virtualisation.libvirtd.qemuOvmf = true;

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

