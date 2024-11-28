path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        hyprpaper
      ];

      services = {
        hyprpaper = {
          enable = true;
          settings = {
            preload = [
              "${hyprCfg.wallpaper}"
            ];
            wallpaper = [
              ",${hyprCfg.wallpaper}"
            ];
          };
        };
      };
    };
  };
}
