{ pkgs, ... }:

let secrets = (import ./secrets.nix);
in {
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  users.users.root = {
    initialPassword = "nixos"; # default console password
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };

  users.users.nixos = {
    initialPassword = "nixos"; # default console password
    openssh.authorizedKeys.keys = secrets.openssh.authorizedKeys.keys;
  };
}
