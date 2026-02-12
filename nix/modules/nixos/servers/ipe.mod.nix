path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;
in
{
  imports = (util.nginx path config).server {
    name = "ipe";
    locations = {
      "/" = {
        extraConfig = "default_type text/plain;";
        return = ''200 "$remote_addr"'';
      };
    };
  };

  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
      forceSSL = lib.mkForce false;
      addSSL = cfg.tls;
    };
  };
}
