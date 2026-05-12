path:
{
  lib,
  config,
  util,
  pkgs,
  options,
  ...
}:
let
  cfg = util.getOptions path config;
  secret = util.secret.mkPath path;
  user = "nextcloud";
in
{
  imports = (util.nginx path config).server {
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

    mail = lib.mkEnableOption "email support through gmail" // {
      default = true;
    };

    sharedDir = lib.mkEnableOption "shared directory for all users" // {
      default = true;
    };

    subvolume = lib.mkEnableOption "btrfs subvolume for the home directory" // {
      default = true;
    };

    snap = lib.mkEnableOption "snapshots of the home directory" // {
      default = cfg.subvolume;
    };

    package = options.services.nextcloud.package // {
      default = pkgs.nextcloud33;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.snap -> cfg.subvolume;
        message = "To take snapshots, Cloud needs its own subvolume";
      }
      {
        assertion = config.celo.modules.services.postgres.enable;
        message = "Nextcloud requires Postgres";
      }
    ];

    age.secrets = {
      ${secret "adminPass"} = {
        rekeyFile = ./_secrets/adminPass.age;
        owner = user;
        group = user;
      };
    };

    services = {
      nextcloud = {
        enable = true;
        package = cfg.package;
        hostName = "${cfg.hostName}.${builtins.head cfg.domains}";
        https = cfg.tls;
        home = cfg.home;

        configureRedis = true;
        database.createLocally = true;
        config = {
          dbtype = "pgsql";
          adminuser = cfg.user;
          adminpassFile = config.age.secrets.${secret "adminPass"}.path;
        };

        extraApps = lib.mkIf cfg.sharedDir {
          groupfolders = cfg.package.packages.apps.groupfolders;
        };

        settings = {
          overwriteprotocol = lib.mkIf cfg.tls "https";
        }
        // lib.optionalAttrs cfg.mail {
          mail_smtpmode = "smtp";
          mail_sendmailmode = "smtp";
          mail_from_address = cfg.hostName;
          mail_domain = builtins.head cfg.domains;
          mail_smtphost = "smtp-relay.gmail.com";
          mail_smtpport = 587;
        };
      };
    };

    systemd.services.nextcloud-setup = {
      postStart = lib.mkAfter "nextcloud-occ app:enable twofactor_totp";
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

    environment = {
      persistence = util.withImpermanence config {
        global.directories = [
          {
            directory = config.services.redis.servers.nextcloud.settings.dir;
            group = user;
            user = user;
            mode = "0755";
          }
        ]
        ++ lib.optional (!cfg.subvolume) {
          directory = cfg.home;
          group = user;
          user = user;
          mode = "0755";
        };
      };
    };
  };
}
