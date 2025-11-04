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

    user = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Admin user name";
      default = config.celo.modules.core.user.userName;
    };

    subvolume = lib.mkEnableOption "btrfs subvolume for the home directory" // {
      default = true;
    };

    snap = lib.mkEnableOption "snapshots of the home directory" // {
      default = cfg.subvolume;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.snap -> cfg.subvolume;
        message = "To take snapshots, Cloud needs its own subvolume";
      }
    ];

    age.secrets = {
      ${secret "config"} = {
        rekeyFile = ./_secrets/config.age;
      };
      ${secret "adminPass"} = {
        rekeyFile = ./_secrets/adminPass.age;
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
        adminuser = cfg.user;
        adminpassFile = config.age.secrets.${secret "adminPass"}.path;
      };

      settings = {
        overwriteprotocol = lib.mkIf cfg.tls "https";
      };

      secretFile = config.age.secrets.${secret "config"}.path;
    };

    celo.modules = lib.mkIf cfg.subvolume {
      core.disko.extraMounts = {
        cloud = {
          name = "@cloud";
          mountpoint = cfg.home;
        };
      };

      services.snapper.mounts = lib.mkIf cfg.snap (lib.mkAfter [ "cloud" ]);
    };

    environment = lib.mkIf (!cfg.subvolume) {
      persistence = util.withImpermanence config {
        global.directories = [
          {
            directory = cfg.home;
            group = "nextcloud";
            user = "nextcloud";
            mode = "0775";
          }
        ];
      };
    };
  };
}
