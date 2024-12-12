path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.hyprland;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [
        breeze-icons
        dolphin
        kcalc
        okular
      ];

      wayland.windowManager.hyprland = {
        settings = {
          env = [
            "QT_QPA_PLATFORM,wayland"
            "QT_QPA_PLATFORMTHEME,qt5ct"
          ];
        };
      };
    };
  };
}
