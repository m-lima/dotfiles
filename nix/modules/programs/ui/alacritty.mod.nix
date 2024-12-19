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
      home = {
        packages = with pkgs; [ alacritty ];
      };

      xdg.configFile."alacritty/alacritty.toml".text =
        ''''
        + builtins.readFile ../../../../alacritty/config/colors.toml
        + builtins.readFile ../../../../alacritty/config/font.toml
        + builtins.readFile ../../../../alacritty/config/options.toml;

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$terminal" = "alacritty";
        };
      };
    };
  };
}
