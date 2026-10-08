path:
{
  lib,
  config,
  pkgs,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
