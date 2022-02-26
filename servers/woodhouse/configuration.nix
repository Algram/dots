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

  services.unifi.enable = false;
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
      acl = [ "pattern readwrite #" ];
      users = {};
    }
  ];

  # networking.nat.enable = true;
  # networking.nat.internalInterfaces = ["ve-homeassistant"];
  # networking.nat.externalInterface = "enp0s25";
  # networking.networkmanager.unmanaged = [ "interface-name:ve-homeassistant" ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/home/woodhouse/hass:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2022.2.9";
      extraOptions = [ 
        "--privileged"
        "--network=host"
      ];
    };
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

  services.home-assistant = {
    enable = false;
    config = {
      homeassistant = {
        name = "Home";
        time_zone = "Europe/Berlin";
        latitude = "0.0";
        longitude = "0.0";
        elevation = 0;
      };
      mqtt = {
        broker = "127.0.0.1";
        port = 1883;
        discovery = true;
      };
      logger = { logs = { "homeassistant.components.mqtt" = "debug"; }; };
      esphome = { };
      wled = { };
      zeroconf = { };
      mobile_app = { };
      recorder = { };
      history = { };
      frontend = { };
      sun = { };
      http = { };
      sensor = [
        {
          name = "temperature_lora_0";
          platform = "mqtt";
          state_topic = "application/1/device/0505050505050505/event/up";
          value_template = "{{ value_json.object.temperature }}";
          unit_of_measurement = "°C";
        }
        {
          name = "humidity_lora_0";
          platform = "mqtt";
          state_topic = "application/1/device/0505050505050505/event/up";
          value_template = "{{ value_json.object.humidity }}";
          unit_of_measurement = "%";
        }
        {
          name = "moisture_lora_0";
          platform = "mqtt";
          state_topic = "application/1/device/0404040404040404/event/up";
          value_template = "{{ value_json.object.moisture }}";
          unit_of_measurement = "%";
        }
      ];
    };
  };

  virtualisation.docker.enable = true;

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

  networking.firewall.allowedTCPPorts = [ 8123 6053 1883 8080 8880 8843 8443 ];
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

