{
  pkgs,
  lib,
  config,
  sysconfig,
  util,
  ...
}:
let
  cfg = config.home.ui.programs.alacritty;
in {
  options = {
    home.ui.programs.alacritty = {
      enable = util.mkDisableOption "alacritty";
    };
  };

  config = util.mkIfUi sysconfig cfg.enable {
    home.packages = with pkgs; lib.mkAfter [ alacritty ];
  };
}
