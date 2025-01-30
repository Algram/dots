{
  username = "";
  hostname = "";

  openssh.authorizedKeys.keys = [ ];

  domain = "";

  acme.email = "";

  acme.cloudflare.credentials = ''
    CLOUDFLARE_EMAIL=
    CLOUDFLARE_API_KEY=
  '';

  influxdb.username = "";
  influxdb.password = "";
  influxdb.organization = "";
  influxdb.telegraf.token = "";
}
