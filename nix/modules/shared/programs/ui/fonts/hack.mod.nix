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

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      fonts.fontconfig.enable = true;

      home.packages =
        if config.celo.modules.programs.ui.alacritty.enable then
          [ pkgs.nerd-fonts.hack ]
        else
          [ pkgs.hack-font ];
    };
  };
}
