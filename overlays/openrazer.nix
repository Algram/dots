self: super:
{
  openrazerOverlay = super.pkgs.openrazer-daemon.overrideAttrs (old: rec {
    version = "2.8.0";
    src = self.fetchFromGitHub {
      owner = "nightsky30";
      repo = "openrazer";
      rev = "v2.9.0";
      sha256 = "013r9q4xg2xjmyxybx07zsl2b5lm9vw843anx22ygpvxz1qgz9hp";
    };
  });
}