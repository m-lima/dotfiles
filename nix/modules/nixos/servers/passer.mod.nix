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
        serviceConfig = {
          Type = "simple";
          User = "passer";
          Group = "passer";
          UMask = "0077";
          WorkingDirectory = cfg.home;
          ExecStart = "${passer.server}/bin/passer --port ${builtins.toString cfg.port} --store-path ${cfg.home}";
          Restart = "on-failure";
          TimeoutSec = 15;

          NoNewPrivileges = true;
          SystemCallArchitectures = "native";
          RestrictAddressFamilies = [ "AF_INET" ];
          RestrictNamespaces = !config.boot.isContainer;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          ProtectControlGroups = !config.boot.isContainer;
          ProtectHostname = true;
          ProtectKernelLogs = !config.boot.isContainer;
          ProtectKernelModules = !config.boot.isContainer;
          ProtectKernelTunables = !config.boot.isContainer;
          LockPersonality = true;
          PrivateTmp = !config.boot.isContainer;
          # needed for hardware acceleration
          PrivateDevices = false;
          PrivateUsers = true;
          RemoveIPC = true;

          SystemCallFilter = [
            "~@clock"
            "~@aio"
            "~@chown"
            "~@cpu-emulation"
            "~@debug"
            "~@keyring"
            "~@memlock"
            "~@module"
            "~@mount"
            "~@obsolete"
            "~@privileged"
            "~@raw-io"
            "~@reboot"
            "~@setuid"
            "~@swap"
          ];
          SystemCallErrorNumber = "EPERM";
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [ cfg.home ];
    };
  };
}
