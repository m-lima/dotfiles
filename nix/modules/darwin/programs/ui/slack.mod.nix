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
      home.packages = [ (pkgs.callPackage ./slack.pkg.nix { }) ];
    };
  };
}
