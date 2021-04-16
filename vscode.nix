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
    package = finalPackage;
    extensions = [ ];
  };
}

# with pkgs.vscode-extensions;
#       [ bbenoist.Nix ms-vsliveshare.vsliveshare ]
#       ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
#         {
#           name = "file-icons";
#           publisher = "file-icons";
#           version = "1.0.24";
#           sha256 = "0mcaz4lv7zb0gw0i9zbd0cmxc41dnw344ggwj1wy9y40d627wdcx";
#         }
#         {
#           name = "vscode-eslint";
#           publisher = "dbaeumer";
#           version = "2.1.6";
#           sha256 = "0xllvrpmxgpmn5f1w8b3gapfyv84r5c3mqy76w5mwcv0snm0981w";
#         }
#         {
#           name = "daily";
#           publisher = "sldobri";
#           version = "6.0.3";
#           sha256 = "0fxin3wq1ysgz4lzpjlal3lba3qd48z5dbqkppyvmg2cvrw500ii";
#         }
#         {
#           name = "gitlens";
#           publisher = "eamodio";
#           version = "10.2.2";
#           sha256 = "00fp6pz9jqcr6j6zwr2wpvqazh1ssa48jnk1282gnj5k560vh8mb";
#         }
#         {
#           name = "graphql-for-vscode";
#           publisher = "kumar-harsh";
#           version = "1.15.3";
#           sha256 = "1x4vwl4sdgxq8frh8fbyxj5ck14cjwslhb0k2kfp6hdfvbmpw2fh";
#         }
#         {
#           name = "mdx";
#           publisher = "silvenon";
#           version = "0.1.0";
#           sha256 = "1mzsqgv0zdlj886kh1yx1zr966yc8hqwmiqrb1532xbmgyy6adz3";
#         }
#         {
#           name = "vscode-mdx-preview";
#           publisher = "xyc";
#           version = "0.3.0";
#           sha256 = "15xbr05a5gj3ncfmb0878bfq1xhyncz31z5hizlq68bnlk3kd1pa";
#         }
#         {
#           name = "prettier-vscode";
#           publisher = "esbenp";
#           version = "5.1.3";
#           sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
#         }
#       ];
