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
  passer = inputs.passer.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = util.nginx path config "api" {
    name = "passer";
    root = "${passer.web}";
    port = 2356;
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/passer";
      description = "Base path for Passer";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf (cfg.hostName != null) {
      virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}".locations = {
        "~ ^/api/(.*)$" = {
          extraConfig = "client_max_body_size 110M;";
        };
      };
    };

    users = {
      users = {
        passer = {
          home = cfg.home;
          group = "passer";
          createHome = true;
          isSystemUser = true;
        };
      };

      groups = {
        passer = { };
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
          ExecStart = "${passer.server}/bin/passer --port ${builtins.toString cfg.port} --store-path ${cfg.home}";
          Restart = "on-failure";
          TimeoutSec = 15;
          WorkingDirectory = cfg.home;

          User = "passer";
          Group = "passer";

          IPAddressAllow = "localhost";
          RestrictAddressFamilies = "AF_INET";
          PrivateNetwork = false;
          ReadWritePaths = cfg.home;
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [ cfg.home ];
    };
  };
}
