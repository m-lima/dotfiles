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
  nginx = util.nginx path config;
  name = "vepeene";
  dnsSecret = util.secret.mkPath path "dns";
in
{
  imports = nginx.server {
    inherit name;
    extras = [
      (nginx.extras.proxy {
        socket = cfg.port;
        ws = true;
      })
    ];
  };

  options = util.mkOptions path {
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to serve the headscale control plane";
      default = 3748;
    };
    nameservers = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      description = "DNS resolvers to use with headscale";
      default = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };
    dns = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to agenix encrypted extra DNS records";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfgNgx.enable;
        message = "Headscale requires nginx to function";
      }
      {
        assertion = cfgNgx.tls;
        message = "Headscale requires TLS to function";
      }
    ];

    age.secrets = lib.mkIf (builtins.isPath cfg.dns) {
      ${dnsSecret} = {
        rekeyFile = cfg.dns;
        owner = "headscale";
      };
    };

    services.headscale = {
      enable = true;
      port = cfg.port;
      settings = {
        server_url = "https://${name}.${cfgNgx.baseHost}";

        dns = {
          magic_dns = true;
          override_local_dns = true;
          base_domain = "celo";
          nameservers.global = cfg.nameservers;
          extra_records_path = lib.mkIf (builtins.isPath cfg.dns) config.age.secrets.${dnsSecret}.path;
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [
        {
          directory = "/var/lib/headscale";
          user = "headscale";
          group = "headscale";
          mode = "0700";
        }
      ];
    };
  };
}
