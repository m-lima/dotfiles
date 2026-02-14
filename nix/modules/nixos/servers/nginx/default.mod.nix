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
      default = util.secret.rageOr config ./_secrets/acmeEmail.rage null;
    };

    enableAcme = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      visible = false;
      default = cfg.tls && cfg.baseHost != "localhost" && cfg.baseHost != config.celo.host.id;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableAcme -> cfg.acmeEmail != null;
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
    };

    networking.firewall.allowedTCPPorts = [
      80
    ]
    ++ (lib.optional cfg.tls 443);

    security = lib.mkIf cfg.enableAcme {
      acme = {
        acceptTerms = true;
        defaults.email = cfg.acmeEmail;
      };
    };

    environment = lib.mkIf cfg.enableAcme {
      persistence = util.withImpermanence config {
        global.directories = [
          {
            directory = "/var/lib/acme";
            mode = "0755";
            user = "acme";
            group = "acme";
          }
        ];
      };
    };
  };
}
