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
  wifidog = inputs.wifidog.packages.${pkgs.stdenv.hostPlatform.system}.zig;
  name = "wifidog";
in
{
  options = util.mkOptions path {
    target = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Target IP to monitor. The gateway is a good option";
      example = "10.0.0.1";
    };

    metrics = lib.mkEnableOption "wifidog metrics" // {
      default =
        let
          grafo = config.celo.modules.servers.grafo;
        in
        grafo.enable && grafo.scrapers.wifidog;
    };

    attempts = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      description = "Number of attempts before considering a failed check";
      default = null;
    };

    interval = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      description = "Seconds to wait between sending pings";
      default = null;
    };

    backoffSuccess = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      description = "Seconds to wait between successful checks";
      default = null;
    };

    backoffFail = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      description = "Cummulative seconds to wait between failed checks";
      default = null;
    };

    backoffError = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      description = "Minutes to wait after a connection error";
      default = null;
    };

    reconnector = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
      description = "Command and arguments to use for reassociation";
      default = [
        "${pkgs.wpa_supplicant}/bin/wpa_cli"
        "reassociate"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${name} = { };
      users = {
        ${name} = {
          group = name;
          createHome = false;
          isSystemUser = true;
        };
      };
    };

    systemd = {
      services.wifidog = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Wifidog";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart =
            let
              # TODO: This location is shared across all that want to log to file
              argMetrics = lib.optionalString cfg.metrics " -m telegraf:/var/run/telegraf/telegraf.sock";
              argAttempts = lib.optionalString (builtins.isInt cfg.attempts) " -a ${toString cfg.attempts}";
              argInterval = lib.optionalString (builtins.isInt cfg.interval) " -i ${toString cfg.interval}";
              argBackoffSuccess = lib.optionalString (builtins.isInt cfg.backoffSuccess) " -s ${toString cfg.backoffSuccess}";
              argBackoffFail = lib.optionalString (builtins.isInt cfg.backoffFail) " -f ${toString cfg.backoffFail}";
              argBackoffError = lib.optionalString (builtins.isInt cfg.backoffError) " -e ${toString cfg.backoffError}";
            in
            ''${wifidog}/bin/wifidog -t "${cfg.target}"${argMetrics}${argAttempts}${argInterval}${argBackoffSuccess}${argBackoffFail}${argBackoffError} ${
              builtins.concatStringsSep " " (map (x: ''"${x}"'') cfg.reconnector)
            }'';

          BindPaths = lib.mkIf cfg.metrics "/var/run/telegraf/telegraf.sock";

          User = name;
          SupplementaryGroups = [
            "wheel"
            "telegraf"
          ];
          ProtectSystem = "full";
          PrivateTmp = false;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_UNIX"
          ];
          PrivateNetwork = false;
          IPAddressAllow = "any";
        };
      };
    };
  };
}
