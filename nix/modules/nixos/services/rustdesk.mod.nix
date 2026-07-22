path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    host = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "FQDN for the host";
    };
  };

  config = lib.mkIf cfg.enable {
    services.rustdesk-server = {
      enable = true;
      openFirewall = true;
      signal.relayHosts = [ cfg.host ];
    };
  };
}
