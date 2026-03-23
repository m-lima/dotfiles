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
  wifidog = inputs.wifidog.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options = util.mkOptions path {
    target = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Target IP to monitor. The gateway is a good option";
      example = "10.0.0.1";
    };

    reassociator = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
      description = "Command and arguments to use for reassociation";
      default = [
        "wpa_cli"
        "reassociate"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.wifidog = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Wifidog";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart = ''${wifidog}/bin/wifidog "${cfg.target}" ${
            builtins.concatStringsSep " " (map (x: ''"${x}"'') cfg.reassociator)
          }'';

          RestrictAddressFamilies = "AF_INET";
          PrivateNetwork = false;
          IPAddressAllow = "any";
        };
      };
    };
  };
}
