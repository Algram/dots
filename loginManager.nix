{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  # services.xserver.enable = true;
  # services.xserver.displayManager.defaultSession = "sway";
  # services.xserver.displayManager.lightdm = {
  #   enable = true;
  #   greeters.pantheon.enable = true;
  # };
  # services.xserver.libinput.enable = true;
  # services.xserver.layout = "us";

  # services.xserver.enable = true;
  # services.xserver.displayManager.defaultSession = "sway";


  # systemd.tmpfiles.rules = [
  #   "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
  #     <!-- this should all be copied from your ~/.config/monitors.xml -->
  #     <monitors version="2">
  #       <configuration>
  #         <logicalmonitor>
  #           <x>0</x>
  #           <y>0</y>
  #           <scale>1</scale>
  #           <primary>yes</primary>
  #           <monitor>
  #             <monitorspec>
  #               <connector>DP-0</connector>
  #               <vendor>XYZ</vendor>
  #               <product>ABC123</product>
  #               <serial>DEF456</serial>
  #             </monitorspec>
  #             <mode>
  #               <width>2560</width>
  #               <height>1440</height>
  #               <rate>144</rate>
  #             </mode>
  #           </monitor>
  #         </logicalmonitor>
  #       </configuration>
  #     </monitors>
  #   ''}"
  # ];


  # services.xserver.displayManager.gdm = {
  #   enable = true;
  #   wayland = true;
  # }; 

  #   # Extracted from nixos/modules/services/x11/xserver.nix
  # systemd.defaultUnit = "graphical.target";
  # systemd.services.display-manager =
  #   let
  #     cfg = config.services.xserver.displayManager;
  #   in
  #   {
  #     description = "Display Manager";

  #     after = [ "acpid.service" "systemd-logind.service" ];

  #     restartIfChanged = false;

  #     environment =
  #       lib.optionalAttrs
  #         config.hardware.opengl.setLdLibraryPath {
  #         LD_LIBRARY_PATH = pkgs.addOpenGLRunpath.driverLink;
  #       } // cfg.job.environment;

  #     preStart =
  #       ''
  #         ${cfg.job.preStart}

  #         rm -f /tmp/.X0-lock
  #       '';

  #     script = "${cfg.job.execCmd}";

  #     serviceConfig = {
  #       Restart = "always";
  #       RestartSec = "200ms";
  #       SyslogIdentifier = "display-manager";
  #       # Stop restarting if the display manager stops (crashes) 2 times
  #       # in one minute. Starting X typically takes 3-4s.
  #       StartLimitInterval = "30s";
  #       StartLimitBurst = "3";
  #     };
  #   };

  # services.xserver.enable = true;
  # services.displayManager.defaultSession = "sway";
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = secrets.username;
  # services.displayManager.lightdm = {
  #   enable = true;
  #   greeters.pantheon.enable = true;
  # };
  # services.libinput.enable = true;
  # services.xserver.xkb.layout = "us";
  # services.xserver.dpi = 96;

  services.gnome.gnome-keyring.enable = true;
}
