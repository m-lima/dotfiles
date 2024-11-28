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

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      # TODO: The TTY changes, causing a blank screen
      sugarCandyNix = {
        enable = true;
        settings = {
          Background = lib.cleanSource hyprCfg.wallpaper;
          ScreenWidth = 3840;
          ScreenHeight = 2160;
          FullBlur = true;
          MainColor = "#${hyprCfg.color.foreground}";
          BackgroundColor = "#${hyprCfg.color.background}";
          AccentColor = "#${hyprCfg.color.accent}";
          OverrideLoginButtonTextColor = "#${hyprCfg.color.background}";
          ForceHideCompletePassword = true;
        };
      };
    };
  };
}
