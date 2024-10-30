{
  pkgs,
  lib,
  sysconfig,
  ...
}:
with lib;
let
  cfg = sysconfig.modules.ui;
in mkIf cfg.ui.enable {
  home.packages = with pkgs; [
    hyprland
  ];

  # TODO: Fonts
}
