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
      sddm = {
        enable = util.mkDisableOption "SDDM";
      };
    };
  };

  config = util.mkIfUi config cfg.enable {
    programs.hyprland = {
      enable = true;
    };
    services.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      wayland.enable = true;
    };
  };
}
