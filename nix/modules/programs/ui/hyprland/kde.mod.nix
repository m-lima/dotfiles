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
        kdePackages.kwallet-pam
        kdePackages.kwalletmanager
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

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".local/share/kwalletd"
      ];
      home.files = [
        ".config/kwalletrc"
      ];
    };
  };
}
