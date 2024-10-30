{
  pkgs,
  lib,
  sysconfig,
  ...
}:
with lib;
let
  cfg = sysconfig.modules;
in mkIf cfg.ui {

  home.packages = with pkgs; [
    hyprland
  ];

  # TODO: Fonts
}
