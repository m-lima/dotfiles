path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  secret = util.secret.mkPath path;
  cfgNgx = config.celo.modules.servers.nginx;
in
{
  imports = util.nginx path config "minimal" {
    name = "cloud";
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/cloud";
      description = "Base path for Cloud";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      ${secret "config"} = {
        rekeyFile = ./_secrets/config.age;
      };
      ${secret "admin"} = {
        rekeyFile = ./_secrets/admin.age;
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      hostName = "${cfg.hostName}.${cfgNgx.baseHost}";
      https = cfg.tls;
      home = cfg.home;

      configureRedis = true;
      caching.redis = true;
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminuser = "mestre";
        adminpassFile = config.age.secrets.${secret "admin"}.path;
      };

      settings = {
        overwriteprotocol = lib.mkIf cfg.tls "https";
      };

      secretFile = config.age.secrets.${secret "config"}.path;
    };
  };
}
