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
    baseHost = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "FQDN for the whole host";
      default = "localhost";
    };

    tls = lib.mkEnableOption "Automatically generate certificates";

    acmeEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.singleLineStr;
      description = "Email to use for ACME registration";
    };
  };

  config =
    let
      shouldAcme = cfg.tls && cfg.baseHost != "localhost" && cfg.baseHost != config.celo.host.id;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = shouldAcme -> cfg.acmeEmail != null;
          message = "Need to specify a hostName to have TLS termination";
        }
        {
          assertion = cfg.tls -> config.services.nginx.enable;
          message = "Need to enable nginx to have TLS termination";
        }
      ];

      services.nginx = {
        enable = true;
        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = cfg.tls;

        statusPage = true;
        commonHttpConfig = ''
          log_format main '$host '
                          '- $remote_addr $request_method $request_uri ''${request_length}b '
                          '- $status ''${bytes_sent}b ''${request_time}s '
                          '- $http_user_agent';

          access_log syslog:server=unix:/dev/log main;
          more_clear_headers Server;
        '';

        virtualHosts = {
          ${cfg.baseHost} = {
            default = true;
            addSSL = cfg.tls;
            enableACME = shouldAcme;

            locations = {
              "/" = {
                return = 444;
              };
            };
          };
        };
      };

      security = lib.mkIf shouldAcme {
        acme = {
          acceptTerms = true;
          defaults.email = cfg.acmeEmail;
        };
      };
    };
}
