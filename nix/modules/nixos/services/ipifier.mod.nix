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
  ipifier = inputs.ipifier.packages.${pkgs.stdenv.hostPlatform.system}.noTimestamp;
  secret = util.secret.mkPath path "config";
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
        serviceConfig = util.systemd.harden {
          Type = "oneshot";

          LoadCredential = "CONFIG:${config.age.secrets.${secret}.path}";
          RestrictAddressFamilies = "AF_INET";
          PrivateNetwork = false;
          IPAddressAllow = "any";
        };

        wantedBy = [ "multi-user.target" ];
        script = "${ipifier}/bin/ipifier $CREDENTIALS_DIRECTORY/CONFIG";
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
