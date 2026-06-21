path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;
  nginx = util.nginx path config;
  skull = inputs.skull.packages.${pkgs.stdenv.hostPlatform.system};
  user = "skull";
  group = user;
  secret = util.secret.mkPath path;
in
{
  imports = nginx.server {
    name = "skull";
    extras = [
      (nginx.extras.serve {
        root = "${skull.web.overrideAttrs (prev: {
          env = (prev.env or { }) // {
            VITE_URL_TLS = "true";
            VITE_URL_HOST = "${cfg.hostName}.${cfgNgx.baseHost}";
            VITE_URL_AUTH = "${config.celo.modules.servers.endgame.hostName}.${cfgNgx.baseHost}";
          };
        })}";
      })
      (nginx.extras.proxy {
        socket = "unix:/run/skull/socket";
        location = "/api/";
        endgame = {
          enable = true;
          autoLogin = true;
        };
      })
      (nginx.extras.proxy {
        socket = "unix:/run/skull/socket";
        location = "/ws/";
        proxyPath = "ws/";
        ws = true;
        endgame = {
          enable = true;
          autoLogin = false;
        };
      })
    ];
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/skull";
      description = "Base path for Skull";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${user} = {
          home = cfg.home;
          group = group;
          createHome = true;
          isSystemUser = true;
        };

        ${config.services.nginx.user}.extraGroups = lib.mkAfter [ group ];
      };

      groups = {
        ${group} = { };
      };
    };

    age.secrets = {
      ${secret "users"} = {
        rekeyFile = ./_secrets/users.age;
        owner = user;
        group = user;
      };
    };

    systemd = {
      services.skull = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Skull";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart = builtins.concatStringsSep " " [
            "${skull.server}/bin/skull-server"
            "--socket ${toString cfg.socket}"
            "--users ${config.age.secrets.${secret "users"}.path}"
            "--create"
            "-vv"
            "${cfg.home}"
          ];
          Restart = "on-failure";
          TimeoutSec = 15;
          WorkingDirectory = cfg.home;

          UMask = "0007";
          User = user;
          Group = group;

          RestrictAddressFamilies = "AF_UNIX";
          RuntimeDirectory = "skull";
          RuntimeDirectoryMode = "0750";
          ReadWritePaths = cfg.home;
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [
        {
          directory = cfg.home;
          mode = "0700";
          user = user;
          group = group;
        }
      ];
    };
  };
}
