{
  lib,
  mkPath,
  mkOptions,
  getOptions,
}:
{
  expose =
    port: path: config:
    let
      cfg = getOptions path config;
      cfgNgx = config.celo.modules.services.nginx;
    in
    [
      {
        options = mkPath path {
          hostName = lib.mkOption {
            type = lib.types.nullOr lib.types.singleLineStr;
            description = "Hostname to expose this service through nginx";
          };

          tls = lib.mkEnableOption "TLS through nginx reverse proxy" // {
            default = cfgNgx.tls;
          };

          port = lib.mkOption {
            type = lib.types.port;
            description = "Port to serve from";
            default = port;
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.tls -> cfg.hostName != null;
              message = "Need to specify a hostName to have TLS termination";
            }
            {
              assertion = cfg.tls -> cfgNgx.enable;
              message = "Need to enable nginx to have TLS termination";
            }
            {
              assertion = cfg.tls -> cfgNgx.tls;
              message = "Need to enable TLS in nginx to have TLS termination";
            }
          ];

          services = {
            nginx = lib.mkIf (cfg.hostName != null) {
              virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
                forceSSL = cfg.tls;
                enableACME = cfg.tls;

                locations = {
                  "/" = {
                    proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
                    recommendedProxySettings = true;
                  };
                };
              };
            };
          };
        };
      }
    ];
}
