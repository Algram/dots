{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    zsh
    git
    htop
    wget
    qemu_kvm
    virt-manager
    libvirt
    bridge-utils
    usbutils
    lm_sensors
  ];
}
