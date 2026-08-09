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
  xdg = util.xdg config;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [
        pkgs.breeze-icons
        pkgs.dolphin
        pkgs.kcalc
        pkgs.kdePackages.kwallet-pam
        pkgs.kdePackages.kwalletmanager
        pkgs.okular
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

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "dataHome"}/kwalletd"
      ];
      home.files = [
        "${xdg.rel "configHome"}/kwalletrc"
      ];
    };
  };
}
