{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in
{
  imports = [
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos") 
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${secrets.username} = { pkgs, ... }: {
    imports = [
      ./sway.nix
      ./mako.nix
      ./waybar.nix
      ./kitty.nix
      ./rofi.nix
    ];

    home.stateVersion = "21.03";

    home.sessionVariables = {
      # Fix antialasing ?
      FREETYPE_PROPERTIES = truetype:interpreter-version=35;
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_CURRENT_DESKTOP = "sway";# https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
      XDG_SESSION_TYPE = "wayland";# https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
    };

    fonts.fontconfig.enable = true;

    gtk = {
      enable = true;
      iconTheme = {
        name = "Numix-Circle";
        package = pkgs.numix-icon-theme-circle;
      };
      theme = {
        name = "Materia-light-compact";
        package = pkgs.materia-theme;
      };
    };

    programs.firefox = {
      enable = true;
      # Until https://github.com/nix-community/home-manager/issues/1641 is fixed
      package = pkgs.firefox-wayland;
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   https-everywhere
      #   privacy-badger
      #   ublock-origin
      #   decentraleyes
      # ];

      profiles.default = {
        path = "1utyytkx.default";

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        # userChrome = builtins.readFile ./dotfiles/userChrome/userChrome.css;
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
    };

    services.gammastep = {
      enable = true;
      # Berlin coordinates
      latitude = "52.5200";
      longitude = "13.405";
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "file-icons";
          publisher = "file-icons";
          version = "1.0.24";
          sha256 = "0mcaz4lv7zb0gw0i9zbd0cmxc41dnw344ggwj1wy9y40d627wdcx";
        }
        {
          name = "vscode-eslint";
          publisher = "dbaeumer";
          version = "2.1.6";
          sha256 = "0xllvrpmxgpmn5f1w8b3gapfyv84r5c3mqy76w5mwcv0snm0981w";
        }
        {
          name = "daily";
          publisher = "sldobri";
          version = "6.0.3";
          sha256 = "0fxin3wq1ysgz4lzpjlal3lba3qd48z5dbqkppyvmg2cvrw500ii";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "10.2.2";
          sha256 = "00fp6pz9jqcr6j6zwr2wpvqazh1ssa48jnk1282gnj5k560vh8mb";
        }
        {
          name = "graphql-for-vscode";
          publisher = "kumar-harsh";
          version = "1.15.3";
          sha256 = "1x4vwl4sdgxq8frh8fbyxj5ck14cjwslhb0k2kfp6hdfvbmpw2fh";
        }
        {
          name = "mdx";
          publisher = "silvenon";
          version = "0.1.0";
          sha256 = "1mzsqgv0zdlj886kh1yx1zr966yc8hqwmiqrb1532xbmgyy6adz3";
        }
        {
          name = "vscode-mdx-preview";
          publisher = "xyc";
          version = "0.3.0";
          sha256 = "15xbr05a5gj3ncfmb0878bfq1xhyncz31z5hizlq68bnlk3kd1pa";
        }
        {
          name = "prettier-vscode";
          publisher = "esbenp";
          version = "5.1.3";
          sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
        }
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

