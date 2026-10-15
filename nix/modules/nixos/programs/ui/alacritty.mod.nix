path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in
{
  config =
    lib.mkIf cfg.enable (
      util.mkPath path {
        exec = "${cfg.pkg}/bin/alacritty";
      }
    )
    // {
      home-manager = util.given.home config {
        wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
          settings = {
            "$terminal" = "${cfg.pkg}/bin/alacritty";
          };
        };
      };
    };
}
