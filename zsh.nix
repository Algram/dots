{ config, pkgs, lib, ... }: {
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
      upgrade = "sudo nixos-rebuild switch --upgrade";
      upgrade-woodhouse = "terraform -chdir=/etc/nixos/servers/woodhouse plan && terraform -chdir=/etc/nixos/servers/woodhouse apply -auto-approve";
      upgrade-barkley = "terraform -chdir=/etc/nixos/servers/barkley plan && terraform -chdir=/etc/nixos/servers/barkley apply -auto-approve";
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
