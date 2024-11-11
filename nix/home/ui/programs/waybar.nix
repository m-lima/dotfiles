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
        };
      };
    };
  };
}
