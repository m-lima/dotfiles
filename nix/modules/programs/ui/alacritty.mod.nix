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

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome config path) ];

    home-manager = util.withHome config {
      home = {
        packages = with pkgs; [ alacritty ];
      };

      xdg.configFile."alacritty/alacritty.toml".text = builtins.readFile ../../../../alacritty/config/colors.toml;

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$terminal" = "alacritty";
        };
      };
    };
  };
}
