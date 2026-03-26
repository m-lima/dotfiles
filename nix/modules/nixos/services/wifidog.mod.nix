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
  user = "wifidog";
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
        "${pkgs.wpa_supplicant}/bin/wpa_cli"
        "reassociate"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${user} = { };
      users = {
        ${user} = {
          group = user;
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
          ExecStart = ''${wifidog}/bin/wifidog "${cfg.target}" ${
            builtins.concatStringsSep " " (map (x: ''"${x}"'') cfg.reassociator)
          }'';

          User = user;
          SupplementaryGroups = "wheel";
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
