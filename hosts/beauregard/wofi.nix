{ config, pkgs, ... }:
let wal = builtins.fromJSON (builtins.readFile /etc/nixos/dotfiles/colors.json);
in {
  home.file = {
    ".config/wofi/style.css" = {
      text = ''
        * {
          font-family: 'CaskaydiaMono Nerd Font', monospace;
          font-size: 18px;
        }

        window {
          margin: 0px;
          padding: 20px;
          background-color: #${wal.colors.color0};
          opacity: 0.95;
        }

        #inner-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: #${wal.colors.color0};
        }

        #outer-box {
          margin: 0;
          padding: 20px;
          border: none;
          background-color: #${wal.colors.color0};
        }

        #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: #${wal.colors.color0};
        }

        #input {
          margin: 0;
          padding: 10px;
          border: none;
          background-color: #${wal.colors.color0};
          color: @text;
        }

        #input:focus {
          outline: none;
          box-shadow: none;
          border: none;
        }

        #text {
          margin: 5px;
          border: none;
          color: #${wal.colors.color6};
        }

        #entry {
          background-color: #${wal.colors.color0};
        }

        #entry:selected {
          outline: none;
          border: none;
        }

        #entry:selected #text {
          color: #${wal.colors.color2};
        }

        #entry image {
          -gtk-icon-transform: scale(0.7);
        }
      '';
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
  };
}
