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
      fonts.fontconfig.enable = true;

      home.packages = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
    };
  };
}
