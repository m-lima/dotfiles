path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    interface = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Name of the interface to set static IP to";
    };
    ip = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Static value to use as IP";
    };
    nameservers = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      description = "IP of the DNS resolver";
      default = [ cfg.gateway ];
    };
    gateway = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Gateway for the network";
    };
    wakeOnLan = lib.mkEnableOption "wake-on-lan";
    initrdModules = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      description = "Modules to load for initrd static IP. And empty value disables this feature";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      interfaces.${cfg.interface} = {
        wakeOnLan = lib.mkIf cfg.wakeOnLan {
          enable = true;
        };

        ipv4.addresses = [
          {
            address = cfg.ip;
            prefixLength = 24;
          }
        ];
        useDHCP = false;
      };
      defaultGateway = cfg.gateway;
      nameservers = cfg.nameservers;
    };

    boot = lib.mkIf (cfg.initrdModules != [ ]) {
      initrd = {
        availableKernelModules = cfg.initrdModules;
        systemd.network = {
          enable = true;
          networks."10-static" = {
            matchConfig.Name = cfg.interface;
            address = [ "${cfg.ip}/24" ];
            gateway = [ cfg.gateway ];
            dns = [ cfg.gateway ];
          };
        };
      };
    };
  };
}
