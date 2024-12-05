path:
{ lib, util, ... }:
{
  options = util.mkOptionsRaw path {
    hostName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Host name";
      example = "coal";
    };
  };
}
