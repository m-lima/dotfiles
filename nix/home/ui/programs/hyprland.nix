{
  pkgs,
  lib,
  config,
  sysconfig,
  util,
  ...
}:
let
  cfg = sysconfig.modules.ui.programs.hyprland;
in util.mkIfUi sysconfig cfg.enable {
  home.packages = with pkgs; lib.mkAfter [ alacritty ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$terminal" = lib.mkIf config.home.ui.programs.alacritty.enable "alacritty";

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape";
      };
    };
  };
}
