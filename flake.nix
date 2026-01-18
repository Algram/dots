# https://github.com/basnijholt/dotfiles/tree/main/configs/nixos
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    spotifyd-pr.url = "github:NixOS/nixpkgs/pull/463287/head";

    hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, disko, spotifyd-pr, ... }:
    let
      system = "x86_64-linux";

      python = nixpkgs.legacyPackages.x86_64-linux.python310;
      pythonPkgs = python.pkgs;

      commonModules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];

      mkHost = extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ extraModules;
        };

    in {
      nixosConfigurations = {
        beauregard = mkHost [
          ./hosts/beauregard/configuration.nix
          ./hosts/beauregard/hardware-configuration.nix
          {
            home-manager.users.raphael = {
              imports = [ ./hosts/beauregard/home.nix ];
            };
          }
        ];

        barkley = mkHost [
          ./hosts/barkley/configuration.nix
          ./hosts/barkley/hardware-configuration.nix
          { home-manager.users.barkley = import ./hosts/barkley/home.nix; }
          {
            nixpkgs.overlays = [
              (final: prev: {
                spotifyd = spotifyd-pr.legacyPackages.${prev.system}.spotifyd;
              })
              (import ./overlays/sendspin-cli.nix)
            ];
          }
        ];

        james = mkHost [
          disko.nixosModules.disko
          ./modules/common.nix
          ./modules/packages.nix
          ./modules/incus.nix
          ./hosts/james/configuration.nix
          ./hosts/james/hardware-configuration.nix
        ];

        lurch = mkHost [
          disko.nixosModules.disko
          ./modules/common.nix
          ./modules/packages.nix
          ./modules/incus.nix
          ./hosts/lurch/configuration.nix
          ./hosts/lurch/hardware-configuration.nix
        ];

        pogo = mkHost [
          disko.nixosModules.disko
          ./modules/common.nix
          ./modules/packages.nix
          ./modules/incus.nix
          ./hosts/pogo/configuration.nix
          ./hosts/pogo/hardware-configuration.nix
          { home-manager.users.pogo = import ./hosts/pogo/home.nix; }
        ];

        higgins = mkHost [
          ./hosts/higgins/configuration.nix
          ./hosts/higgins/hardware-configuration.nix
          { home-manager.users.higgins = import ./hosts/higgins/home.nix; }
        ];

        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import (nixpkgs
              + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"))
            ./installers/iso.nix
          ];
        };
      };
    };
}
