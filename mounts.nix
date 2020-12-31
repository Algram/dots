{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in {
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/home/${secrets.hostname}/Games" ={
    device = "/dev/nvme0n1p3";
    fsType = "ntfs"; 
    options = [ "rw" ];
  };
}

  
