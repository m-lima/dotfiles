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
  imports = util.nginx.expose 1337 path config;

  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.celo.modules.services.rtor.enable;
        message = "Flood requires rtor to be enabled";
      }
    ];

    services.flood = {
      enable = true;
      openFirewall = true;
      port = cfg.port;
      extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
    };

    systemd.services.flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
  };
}
