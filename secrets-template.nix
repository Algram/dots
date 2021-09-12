{
  username = "";
  hostname = "";

  networking.extraHosts = "";

  openssh.authorizedKeys.keys = [ ];

  syncthing = {
    devices = {
      some_device.addresses = [ ];
      some_device.id = "";
      some_device.introducer = true;
    };

    folders = {
      some_folder.id = "";
      some_folder.type = "";
      some_folder.path = "";
    };
  };
}
