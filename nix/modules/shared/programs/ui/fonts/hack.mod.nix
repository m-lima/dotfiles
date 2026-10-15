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
      fonts.fontconfig.enable = true;

      home.packages = [
        pkgs.nerd-fonts.hack
        pkgs.hack-font
      ];
    };
  };
}
