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
  config = util.enforceHome path config cfg.enable {
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

    # security.pam.services = {
    #   login.kwallet = {
    #     enable = true;
    #     # forceRun = true;
    #     package = pkgs.kdePackages.kwallet-pam;
    #   };
    #   #   kde = {
    #   #     allowNullPassword = true;
    #   #     kwallet = {
    #   #       enable = true;
    #   #       forceRun = true;
    #   #       package = pkgs.kdePackages.kwallet-pam;
    #   #     };
    #   #   };
    # };
  };
}
