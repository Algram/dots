let cfgDir = ./.;
in {
  home.file.".config/makima/Wireless Controller.toml".source = cfgDir
    + "/Wireless Controller.toml";

  home.file.".config/makima/Wireless Steam Controller.toml".source = cfgDir
    + "/Wireless Steam Controller.toml";

  home.file.".config/makima/Wireless Controller::Kodi.toml".source = cfgDir
    + "/Wireless Controller::Kodi.toml";
}
