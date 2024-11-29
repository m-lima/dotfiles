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
in
{
  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      # TODO: The TTY changes, causing a blank screen
      sugarCandyNix = {
        enable = true;
        settings = {
          Background = lib.cleanSource cfg.wallpaper;
          ScreenWidth = 3840;
          ScreenHeight = 2160;
          FullBlur = true;
          MainColor = "#${cfg.color.foreground}";
          BackgroundColor = "#${cfg.color.background}";
          AccentColor = "#${cfg.color.accent}";
          OverrideLoginButtonTextColor = "#${cfg.color.background}";
          ForceHideCompletePassword = true;
        };
      };
    };
  };
}
