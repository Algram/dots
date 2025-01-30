{ config, pkgs, lib, ... }:
let
  secrets = import ./secrets.nix;
in {
  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Shell init can only run on local machine, not on ssh, otherwise rsync breaks
    shellInit = ''if echo "$-" | grep i > /dev/null; then cat ~/.cache/wal/sequences; fi'';
    shellAliases = {
      vim = "nvim";
      config = "code /etc/nixos";
      upgrade = "sudo nixos-rebuild switch --upgrade --impure --flake path:///etc/nixos#beauregard";
      upgrade-woodhouse = "terraform -chdir=/etc/nixos/servers/woodhouse plan && terraform -chdir=/etc/nixos/servers/woodhouse apply -auto-approve";
      # upgrade-barkley = "terraform -chdir=/etc/nixos/servers/barkley plan && terraform -chdir=/etc/nixos/servers/barkley apply -auto-approve";
      upgrade-barkley = "nixos-rebuild switch --flake path:///etc/nixos#barkley --use-remote-sudo --target-host barkley@192.168.1.152 --build-host barkley@192.168.1.152";
      upgrade-higgins = "nixos-rebuild switch --flake path:///etc/nixos#higgins --use-remote-sudo --target-host higgins@192.168.1.153 --build-host higgins@192.168.1.153";
      upgrade-local = "sudo nixos-rebuild switch -I nixpkgs=.";
      k = "kubectl";
    };
    ohMyZsh = {
      enable = true;
      # customPkgs = with pkgs; [
      #   spaceship-prompt
      # ];
      # theme = "spaceship";
      plugins = [ "git" "z" ];
    };
  };
}
