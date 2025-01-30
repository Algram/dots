{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in
{
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/home/${secrets.username}/GamesWindows" = {
    device = "/dev/nvme0n1p3";
    fsType = "ntfs";
    options = [ "rw" ];
  };

  # fileSystems."/mnt/syncthing" = {
  #   device = "//192.168.1.150/syncthing";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #   in ["${automount_opts},username=testuser,password=1234,mfsymlinks,file_mode=0777,dir_mode=0777"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770,cache=loose"];
  #   # in ["username=${secrets.nextcloud.samba.username},password=${secrets.nextcloud.samba.password},uid=993,gid=990,mfsymlinks,file_mode=0770,dir_mode=0770"];
  # };
}

  
