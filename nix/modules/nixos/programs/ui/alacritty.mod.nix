path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$terminal" = "${cfg.pkg}/bin/alacritty";
        };
      };
    };
  };
}
