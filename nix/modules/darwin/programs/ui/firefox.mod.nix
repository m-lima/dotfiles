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
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.firefox.package = (pkgs.callPackage ./firefox.pkg.nix { });
    };
  };
}
