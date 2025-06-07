path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
{
  options = util.mkPath path {
    stateVersion = lib.mkOption {
      description = "See https://mynixos.com/home-manager/option/home.stateVersion";
      example = "25.05";
      type = lib.types.nonEmptyStr;
      default = config.celo.modules.core.system.stateVersion;
    };
  };
}
