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
in {
  config = lib.mkIf cfg.enable {
    home-manager = util.withHome config {
      home.packages = with pkgs; [
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
    };
  };
}
