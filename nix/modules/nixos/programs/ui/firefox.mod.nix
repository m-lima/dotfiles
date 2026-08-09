path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$browser" = "firefox-esr";
        };
      };

    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "configHome"}/mozilla/firefox"
        "${xdg.rel "cacheHome"}/mozilla/firefox"
        ".mozilla"
        "Downloads"
      ];
    };
  };
}
