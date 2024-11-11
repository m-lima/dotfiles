{
  pkgs,
  lib,
  config,
  sysconfig,
  util,
  ...
}:
let
  cfg = sysconfig.modules.ui.programs.hyprland;
in util.mkIfUi sysconfig cfg.enable {
  home.packages = with pkgs; lib.mkAfter [
    hyprpaper
  ];

  services = {
    hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "${cfg.wallpaper}"
        ];
        wallpaper = [
          ",${cfg.wallpaper}"
        ];
      };
    };
  };
}
