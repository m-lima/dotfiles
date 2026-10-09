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
  xdg = util.xdg config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.firefox = {
        package = pkgs.firefox-esr;
        configPath = "${(util.xdg config).abs "configHome"}/mozilla/firefox";
      };

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
