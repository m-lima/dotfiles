{
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.modules.ui.programs.hyprland;
in {
  options = {
    modules.ui.programs.hyprland = {
      enable = util.mkDisableOption "hyprland";
    };
  };

  config = util.mkIfUi config cfg.enable {
    programs.hyprland = {
      enable = true;
    };
  };
}
