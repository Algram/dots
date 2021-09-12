{ config, pkgs, lib, ... }:

let
  # Change the package to the vscode version you wish to use2
  package = pkgs.vscode;

  # extensions = with pkgs.vscode-extensions; [ ms-vsliveshare.vsliveshare ];
  extensions = with pkgs.vscode-extensions; [ ];

  finalPackage = (pkgs.vscode-with-extensions.override {
    vscode = package;
    vscodeExtensions = extensions;
  }).overrideAttrs (old: { inherit (package) pname version; });
in {
  programs.vscode = {
    enable = true;
  };
}