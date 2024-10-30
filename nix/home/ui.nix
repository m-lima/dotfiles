{
  pkgs,
  lib,
  sysconfig,
  ...
}:
let
  cfg = sysconfig.modules.ui;
in lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    hyprland
  ];

  # TODO: Fonts
}
