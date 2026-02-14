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
  nginx = util.nginx path config;
  passer = inputs.passer.packages.${pkgs.stdenv.hostPlatform.system};
  user = "passer";
  group = user;
in
{
  imports = nginx.server {
    name = "passer";
    extras = [
      (nginx.extras.serve {
        root = "${passer.web}";
      })
      (nginx.extras.proxy {
        port = 2356;
        location = "/api/";
        extraConfig = "client_max_body_size 110M;";
      })
    ];
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/passer";
      description = "Base path for Passer";
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
      services.passer = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Passer";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart = "${passer.server}/bin/passer --port ${toString cfg.port} --store-path ${cfg.home}";
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
