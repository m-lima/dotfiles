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
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [ spotify ];

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$player" = "spotify";
        };
      };
    };

    environment = {
      persistence = util.withImpermanence config {
        home.directories = [
          ".config/spotify"
          ".cache/spotify"
        ];
      };
    };
  };
}
