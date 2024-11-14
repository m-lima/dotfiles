path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOption path config;
in {
  options = util.mkModule path {
    description = "mDNS resolution and publishing";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
  };
}
