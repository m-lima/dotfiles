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
in
util.mkIfUi sysconfig cfg.enable {

  fonts.fontconfig.enable = true;

  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
}
