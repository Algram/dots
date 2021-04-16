{ config, pkgs, lib, ... }: {
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Extracted from nixos/modules/services/x11/xserver.nix
  systemd.defaultUnit = "graphical.target";
  systemd.services.display-manager =
    let cfg = config.services.xserver.displayManager;
    in {
      description = "Display Manager";

      after = [ "acpid.service" "systemd-logind.service" ];

      restartIfChanged = false;

      environment = lib.optionalAttrs config.hardware.opengl.setLdLibraryPath {
        LD_LIBRARY_PATH = pkgs.addOpenGLRunpath.driverLink;
      } // cfg.job.environment;

      preStart = ''
        ${cfg.job.preStart}

        rm -f /tmp/.X0-lock
      '';

      script = "${cfg.job.execCmd}";

      # Stop restarting if the display manager stops (crashes) 2 times
      # in one minute. Starting X typically takes 3-4s.
      startLimitIntervalSec = 5;
      startLimitBurst = 3;

      serviceConfig = {
        Restart = "always";
        RestartSec = "200ms";
        SyslogIdentifier = "display-manager";
      };
    };
}
