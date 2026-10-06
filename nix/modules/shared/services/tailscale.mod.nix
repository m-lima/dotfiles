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
  options = util.mkOptions path {
    exitNode = lib.mkOption {
      type = lib.types.bool;
      description = "Use this node as an exit node";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
