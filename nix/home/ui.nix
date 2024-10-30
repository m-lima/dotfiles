{
  pkgs,
  lib,
  sysconfig,
  ...
}:
# TODO: Remove these `with`s and be explicit
with lib;
let
  cfg = sysconfig.modules.ui;
in mkIf cfg.ui.enable {
  home.packages = with pkgs; [
    hyprland
  ];

  # TODO: Fonts
}
