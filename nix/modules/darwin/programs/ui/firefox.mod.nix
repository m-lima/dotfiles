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
  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      programs.firefox.package = (pkgs.callPackage ./firefox.pkg.nix { });
    };
  };
}
