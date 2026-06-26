path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  streamPort = 8484;
  toPort = option: if option == true then 8443 else option;
in
{
  options = util.mkOptions path {
    baseHost = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "FQDN for the whole host";
      default = "localhost";
    };

    tls = lib.mkEnableOption "automatically generate certificates";

    acmeEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.singleLineStr;
      description = "Email to use for ACME registration";
      default = util.secret.rage.orElse config ./_secrets/email.rage null;
    };

    proxyProtocol = lib.mkOption {
      type = lib.types.either lib.types.bool lib.types.port;
      description = ''
        Wether to enable proxy protocol for HTTPS traffic.
        If a port is given, that port will serve the HTTPS traffic with proxy protocol.
        If `true` is given, it will default to 8443.
        And `false` will disable it.
      '';
      default = false;
    };

    streams = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "FQDN for the host to be streamed";
            };
            target = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Target to stream traffic to";
            };
            proxyProtocol = lib.mkOption {
              type = lib.types.either lib.types.bool lib.types.port;
              description = "Port to forward TLS traffic to";
              default = false;
            };
          };
        }
      );
      example = [
        {
          host = "other.domain.com";
          target = "192.168.0.2";
          proxyProtocol = 8443;
        }
      ];
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tls -> config.services.nginx.enable;
        message = "Need to enable nginx to have TLS termination";
      }
      {
        assertion = cfg.tls -> cfg.proxyProtocol != false;
        message = "Cannot set proxy protocol if there is no TLS traffic";
      }
      {
        assertion = cfg.proxyProtocol != 443;
        message = "Cannot serve proxy protocol on port 443";
      }
      {
        assertion = cfg.streams != [ ] -> cfg.proxyProtocol != false;
        message = "Proxy protocol must be enabled if stream-proxying";
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
        log_format main '{'
                          'dst:$host '
                          'src:$remote_addr '
                          'req:[$request_method $request_uri ''${request_length}b] '
                          'res:[$status ''${bytes_sent}b ''${request_time}s] '
                          'usr:[$endgame_email $endgame_given_name $endgame_family_name $http_user_agent]'
                        '}';

        access_log syslog:server=unix:/dev/log main;
        more_clear_headers Server;
      '';

      defaultListen =
        if cfg.proxyProtocol != false then
          [
            { addr = "0.0.0.0"; }
            {
              addr = "0.0.0.0";
              port = toPort cfg.proxyProtocol;
              ssl = true;
              proxyProtocol = true;
            }
          ]
        else
          [ ];

      virtualHosts = {
        ${cfg.baseHost} = {
          default = true;
          rejectSSL = true;
          extraConfig = "return 444;";
        };
      }
      // (builtins.listToAttrs (
        map (s: {
          name = ".${s.host}";
          value = {
            locations."/" = {
              proxyPass = "http://${s.target}:80";
              recommendedProxySettings = true;
            };
          };
        }) cfg.streams
      ));

      streamConfig =
        let
          streams = builtins.filter (s: s.proxyProtocol != false) cfg.streams;
        in
        lib.mkIf (streams != [ ]) ''
          tcp_nodelay on;

          map $ssl_preread_server_name $backend_https {
            hostnames;
            ${builtins.concatStringsSep "\n" (
              map (s: ".${s.host} ${s.target}:${toString (toPort s.proxyProtocol)};") streams
            )}
            default 127.0.0.1:${toString (toPort cfg.proxyProtocol)};
          }

          server {
            listen ${toString streamPort};
            ssl_preread on;
            proxy_pass $backend_https;
            proxy_protocol on;
            proxy_connect_timeout 10s;
            proxy_timeout 60s;
          }
        '';
    };

    networking.firewall.allowedTCPPorts = [
      80
    ]
    ++ (lib.optional cfg.tls 443)
    ++ (lib.optional (cfg.streams != [ ]) streamPort)
    ++ (lib.optional (cfg.proxyProtocol != false) (toPort cfg.proxyProtocol));

    security = lib.mkIf cfg.tls {
      acme = {
        acceptTerms = true;
        defaults.email = cfg.acmeEmail;
      };
    };

    environment = lib.mkIf cfg.tls {
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
