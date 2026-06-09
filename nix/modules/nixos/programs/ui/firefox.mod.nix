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
        "${(util.xdg config).configHome}/mozilla/firefox"
        ".mozilla"
        ".cache/mozilla"
        "Downloads"
      ];
    };
  };
}
