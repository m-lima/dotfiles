path:
{
  pkgs,
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
    pkg = lib.mkOption {
      type = lib.types.package;
      default = pkgs.direnv;
    };
  };

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      programs.direnv = {
        enable = true;
        package = cfg.pkg;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
