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
  elo = inputs.elo.packages.${pkgs.stdenv.hostPlatform.system};
  user = "elo";
  group = user;
in
{
  imports = nginx.server {
    name = "elo";
    endgame = true;
    extras = [
      (nginx.extras.serve {
        root = "${elo.front.overrideAttrs (prev: {
          env = (prev.env or { }) // {
            VITE_HOST_WS = "wss://${cfg.hostName}.${cfgNgx.baseHost}/ws/binary";
            VITE_HOST_LOGIN = "https://${config.celo.modules.servers.endgame.hostName}.${cfgNgx.baseHost}/login?redirect=https://${cfg.hostName}.${cfgNgx.baseHost}";
          };
        })}";
      })
      (nginx.extras.proxy {
        port = 2357;
        mode = "ws";
        proxyPath = "/ws/";
        endgame = true;
      })
    ];
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/elo";
      description = "Base path for Elo";
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
      };

      groups = {
        ${group} = { };
      };
    };

    systemd = {
      services.elo = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Elo";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart = builtins.concatStringsSep " " [
            "${elo.back}/bin/elo"
            "--init"
            "--link 'https://${cfg.hostName}.${cfgNgx.baseHost}'"
            "--from 'PongElo <noreply-pongelo@${cfgNgx.baseHost}>'"
            "--smtp 'smtp://smtp-relay.gmail.com:587?tls=required'"
            "--db ${cfg.home}/elo.sqlite"
            "--port ${builtins.toString cfg.port}"
            "-vvv"
          ];
          Restart = "on-failure";
          TimeoutSec = 15;
          WorkingDirectory = cfg.home;

          User = user;
          Group = group;

          IPAddressAllow = "localhost";
          RestrictAddressFamilies = "AF_INET";
          PrivateNetwork = false;
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
