path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
{
  options = util.mkRawOptions path {
    stateVersion = lib.mkOption {
      description = "See https://mynixos.com/nix-darwin/option/system.stateVersion";
      example = 5;
      type = lib.types.int;
    };
  };
}
