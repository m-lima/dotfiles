path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getModuleOption path config;
in {
  options = util.mkModuleEnable path;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
    ];
  };
}
