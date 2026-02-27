path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  nginx = util.nginx path config;
  skull = inputs.skull.packages.${pkgs.stdenv.hostPlatform.system};
  user = "skull";
  group = user;
in
{
  imports = nginx.server {
    name = "skull";
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:3000";
        recommendedProxySettings = true;
      };
    };
    extras = [
      (nginx.extras.proxy {
        socket = "unix:/run/skull/socket";
        location = "/api/";
        endgame = true;
        autoLogin = true;
      })
      (nginx.extras.proxy {
        socket = "unix:/run/skull/socket";
        location = "/ws/";
        proxyPath = "ws/";
        ws = true;
        endgame = true;
        autoLogin = false;
      })
    ];
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/skull";
      description = "Base path for Skull";
    };

    users = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      default = util.secret.rage config /${rootDir}/secrets/general/email.rage;
      description = "Users with access to Skull";
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
            "--users ${pkgs.writeText "users" (lib.concatStringsSep "\n" cfg.users)}"
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
