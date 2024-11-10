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
  home.packages = with pkgs; lib.mkAfter [
    dolphin
    bemenu
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$terminal" = "alacritty";
      "$fileManager" = "dolphin";
      "$launcher" = "bemenu-run";

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape";
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
      };

      bind = [
        "SUPER SHIFT, Q, exit"
        "SUPER, C, killactive"
        "SUPER, E, exec, $fileManager"
        "SUPER, SPACE, exec, $launcher"
        "SUPER, RETURN, exec, $terminal"
      ];
    };
  };
}
