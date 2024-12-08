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

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome path config) ];

    home-manager = util.withHome config { home.packages = with pkgs; [ rage ]; };
  };
}
