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
  ipifier = inputs.ipifier.packages.${pkgs.system}.default;
  secret = util.mkSecretPath path "config";
in
{
  options = util.mkOptions path {
    enable = lib.mkEnableOption "dynamic cloudflare updater";

    configuration = lib.mkOption {
      type = lib.types.path;
      description = "Path to the configuration file agenix encrypted";
      example = "./options.json";
    };

    period = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Period to run the update";
      default = "10min";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      ${secret} = {
        rekeyFile = cfg.configuration;
      };
    };

    systemd = {
      services.ipifier = {
        description = "Ipifier";
        serviceConfig = {
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
        script = "${ipifier}/bin/ipifier ${config.age.secrets.${secret}.path}";
      };

      timers.ipifier = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = cfg.period;
          OnUnitActiveSec = cfg.period;
          Persistent = true;
        };
      };
    };
  };
}
