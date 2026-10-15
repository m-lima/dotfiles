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
  options = util.mkOptionsEnable path;

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      home.packages = [ pkgs.xxd ];
    };
  };
}
