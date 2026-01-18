{ config, pkgs, lib, ... }:
let
  secrets = import ./secrets.nix;
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  # session = "${pkgs.sway}/bin/sway";
  session = "${pkgs.hyprland}/bin/hyprland";
  # inherit (pkgs.kdePackages.plasma) plasma-bigscreen;
in {
  # services.xserver = {
  #   enable = true;

  # };

  # # # services.desktopManager.plasma5.enable = true;
  # # services.xserver.desktopManager.plasma5.bigscreen.enable = true;

  # services.xserver.desktopManager.plasma5.bigscreen.enable = true;

  # services.displayManager.sddm.enable = true;

  # services.xserver.enable = true; # optional
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # # Bigscreen-specific additions:
  # xdg.portal.configPackages = [ plasma-bigscreen ];

  # services.displayManager.sessionPackages = [ plasma-bigscreen ];

  # environment.systemPackages = [ plasma-bigscreen ];

  boot = {
    plymouth = {
      enable = true;
      theme = "red_loader";
      themePackages = with pkgs;
        [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "red_loader" ];
          })
        ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.network.enable = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "module_blacklist=i915"
      "noresume"
      "fastboot"
      # "video=HDMI-A-1:3840x2160@120"
      # "i915.enable_guc=2"
      # "i915.enable_fbc=1"
      # "i915.enable_psr=2"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  services = {
    displayManager = {
      enable = true;
      sessionPackages = [ pkgs.hyprland ];
      autoLogin = {
        enable = true;
        user = "${secrets.username}";
      };
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  services = {
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          # proptest -M amdgpu -D /dev/dri/card0 75 connector 76 10 && ${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}
          command = "hyprland";
          user = "${secrets.username}";
        };
        default_session = initial_session;
      };
    };
  };

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     initial_session = {
  #       command = "${session}";
  #       user = "${secrets.username}";
  #     };
  #     default_session = {
  #       # https://brad-x.com/posts/quick-tip-setting-the-color-space-value-in-wayland/
  #       # command = "proptest -M i915 -D /dev/dri/card1 112 connector 101 1 && ${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
  #       command =
  #         "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
  #       user = "greeter";
  #     };
  #   };
  # };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";
      };
      Policy = { AutoEnable = "true"; };
    };
  };

  services.blueman.enable = true;

  # # As of 25.11
  # services.displayManager.gdm.enable = true;
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "higgins";
  # };
  # services.desktopManager.gnome.enable = true;

  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "account";

  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;
}
