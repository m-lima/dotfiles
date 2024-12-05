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
    assertions = [ (util.assertHome config path) ];

    home-manager = util.withHome config {
      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
  };
}
