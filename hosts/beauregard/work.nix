{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  virtualisation.docker.enable = true;

  users.users.${secrets.username}.extraGroups = [ "docker" ];

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     wayvnc = prev.wayvnc.overrideAttrs
  #       (old: { buildInputs = old.buildInputs ++ [ prev.wlroots ]; });
  #   })
  # ];

  environment.systemPackages = with pkgs; [
    (yarn.override { nodejs = nodejs; })
    google-chrome
    nodejs
    python311
    uv
    libreoffice
    nodePackages.pnpm
    # rustdesk
    wayvnc
  ];

  # services.rustdesk-server.enable = fa;
  # services.rustdesk-server.relay.enable = true;
  # services.rustdesk-server.signal.relayHosts = [ "127.0.0.155" ];
  # services.gnome.gnome-remote-desktop.enable = true;
  # xdg.portal.wlr.enable = true;
}
