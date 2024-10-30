{
  config,
  mkUiIf,
  mkDisableOption,
  ...
}:
let
  cfg = config.modules.ui.programs.hyprland;
in {
  options = {
    modules.ui.programs.hyprland = {
      enable = mkDisableOption "hyprland";
    };
  };

  config = mkUiIf cfg.enable {
    programs.hyprland = {
      enable = true;
    };
  };
}
