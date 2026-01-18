{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    # autosuggestions.enable = true;
    # syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell init can only run on local machine, not on ssh, otherwise rsync breaks
    initContent = ''
      if echo "$-" | grep i > /dev/null; then cat ~/.cache/wal/sequences; fi; [ -n "$HELLO_WORLD" ] && kitten @ set-colors background=#1f1729'';
    shellAliases = {
      # ls replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";

      # Modern replacements
      cat = "bat";
      grep = "rg";
      find = "fd";
      vim = "nvim";
      config = "code /etc/nixos";
      upgrade =
        "sudo nixos-rebuild switch --upgrade --impure --recreate-lock-file --flake path:///etc/nixos#beauregard";
      update =
        "sudo nixos-rebuild switch --upgrade --impure --flake path:///etc/nixos#beauregard";
      upgrade-barkley =
        "nixos-rebuild switch --recreate-lock-file --flake path:///etc/nixos#barkley --use-remote-sudo --target-host barkley@192.168.1.152 --build-host barkley@192.168.1.152";
      upgrade-higgins =
        "nixos-rebuild switch --impure --recreate-lock-file --flake path:///etc/nixos#higgins --use-remote-sudo --target-host higgins@192.168.1.153 --build-host higgins@192.168.1.153";
      update-higgins =
        "nixos-rebuild switch --impure --flake path:///etc/nixos#higgins --use-remote-sudo --target-host higgins@192.168.1.153 --build-host higgins@192.168.1.153";
      upgrade-local = "sudo nixos-rebuild switch -I nixpkgs=.";
      upgrade-pogo =
        "nixos-rebuild switch --recreate-lock-file --flake path:///etc/nixos#pogo --use-remote-sudo --target-host pogo@192.168.1.21 --build-host pogo@192.168.1.21";
      upgrade-lurch =
        "nixos-rebuild switch --recreate-lock-file --flake path:///etc/nixos#lurch --use-remote-sudo --target-host lurch@192.168.1.22 --build-host lurch@192.168.1.22";
      upgrade-james =
        "nixos-rebuild switch --recreate-lock-file --flake path:///etc/nixos#james --use-remote-sudo --target-host james@192.168.1.23 --build-host james@192.168.1.23";
      upgrade-cluster = "upgrade-pogo && upgrade-lurch $$ upgrade-james";
      k = "kubectl";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Will be overridden by starship
      plugins = [
        "git"
        # "z"
        "docker"
        "kubectl"
        "terraform"
        "npm"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "extract"
      ];
    };
  };
}
