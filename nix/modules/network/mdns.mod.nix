path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOpion path config;
in {
  options = util.mkModuleOptionDesc path "mDNS resolution and publishing" {};

  config = lib.mkIf cfg.enable {
    services = {
      avahi = mkIf cfg.mdns.enable {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          domain = true;
          addresses = true;
        };
      };
    };
  };
}
