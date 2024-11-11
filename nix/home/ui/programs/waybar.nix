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
    waybar
  ];

  programs = {
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [
           "hyprland/workspaces"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "clock"
          ];

          "hyprland/workspaces" = {
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";
          };

          clock = {
            format = "{:%a, %d. %b %H:%M}";
          };
        };
      };

      style = ''
        window#waybar {
          color: #${cfg.color.foreground};
          text-shadow: 0 0 4px black;
          background-color: rgba(0, 0, 0, 0.2);

          transition-duration: 0.5s;
          transition-property: background-color;
        }

        .modules-left,
        .modules-right
        {
          padding-right: ${toString cfg.gap.outer}px;
          padding-left: ${toString cfg.gap.outer}px;
        }
      '';
    };
  };
}
