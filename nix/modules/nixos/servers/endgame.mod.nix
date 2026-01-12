path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;
  cfgSysNgx = config.services.nginx;
  endgame = {
    bin = inputs.endgame.packages.${pkgs.stdenv.hostPlatform.system}.default;
    module = inputs.endgame.module.${pkgs.stdenv.hostPlatform.system};
  };
  secret = util.secret.mkPath path "key";
in
{
  options = util.mkOptions path {
    bin = lib.mkEnableOption "Install the cookie generator";

    key = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.singleLineStr;
      description = "Key to use for endgame encryption (cookie & state)";
    };

    clientId = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "OIDC client ID";
    };

    clientSecret = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "OIDC client secret";
    };

    discoveryUrl = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "OIDC discovey document endpoint";
      default = "https://accounts.google.com/";
    };

    sessionTtl = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "How long should the session last for (see https://nginx.org/en/docs/syntax.html)";
      default = "1w";
    };

    hostName = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Hostname to expose endgame locations";
      default = "auth";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfgSysNgx.enable;
        message = "Nginx needs to be enabled for endgame";
      }
      {
        assertion = cfgNgx.tls;
        message = "HTTPS needs to be enabled for endgame";
      }
    ];

    age.secrets = lib.mkIf (builtins.isPath cfg.key) {
      ${secret} = {
        rekeyFile = cfg.key;
        owner = cfgSysNgx.user;
        group = cfgSysNgx.group;
      };
    };

    home-manager = util.withHome config {
      home.packages = [ endgame.bin ];
    };

    services.nginx = {
      commonHttpConfig = lib.mkAfter ''
        endgame_key ${
          if builtins.isPath cfg.key then "file ${config.age.secrets.${secret}.path}" else "raw ${cfg.key}"
        };
        endgame_client_id ${cfg.clientId};
        endgame_client_secret ${cfg.clientSecret};
        endgame_discovery_url ${cfg.discoveryUrl};
        endgame_session_domain ${cfgNgx.baseHost};
        endgame_session_ttl ${cfg.sessionTtl};
        endgame_client_callback_url https://${cfg.hostName}.${cfgNgx.baseHost}/callback;
      '';

      package = pkgs.nginx.override (prev: {
        modules = prev.modules ++ [ endgame.module ];
      });

      virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
        forceSSL = true;
        enableACME = cfgNgx.enableAcme;

        locations = {
          "/" = {
            return = 444;
          };

          "= /logout" = {
            extraConfig = ''
              add_header Set-Cookie 'endgame=;Path=/;Domain=${cfgNgx.baseHost};Max-Age=0;Secure;HttpOnly;SameSite=lax';

              if ($arg_redirect ~ .+) {
                return 302 $arg_redirect;
              }

              default_type text/plain;
              return 200 'Logged Out';
            '';

          };

          "= /callback" = {
            extraConfig = "endgame callback;";
          };
        };
      };
    };
  };
}
