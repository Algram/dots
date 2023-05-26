{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
  };

  # environment.systemPackages = with pkgs; [
  #   nixfmt
  # ];
}