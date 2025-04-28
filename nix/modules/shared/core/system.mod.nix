path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  host = config.celo.host.id;
in
{
  options = util.mkOptions path {
    hostName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Host name";
      default = host;
      example = "coal";
    };
    timeZone = lib.mkOption {
      description = "TimeZone to use";
      example = "Europe/Amsterdam";
      default = null;
      type = lib.types.nullOr lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    # Define the hostname
    networking.hostName = cfg.hostName;

    # Set the time zone.
    time.timeZone = cfg.timeZone;

    system.stateVersion = cfg.stateVersion;
  };
}
