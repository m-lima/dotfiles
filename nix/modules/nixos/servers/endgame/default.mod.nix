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
  secretKey = util.secret.mkPath path "key";
  secretClientId = util.secret.mkPath path "clientId";
  secretClientSecret = util.secret.mkPath path "clientSecret";
in
{
  options = util.mkOptions path {
    bin = lib.mkEnableOption "Install the cookie generator";

    key = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.singleLineStr;
      description = "Key to use for endgame encryption (cookie & state)";
    };

    clientId = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.singleLineStr;
      description = "OIDC client ID";
      default = ./_secrets/client_id.age;
    };

    # TODO: Allow passing in a file to use with agenix
    clientSecret = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.singleLineStr;
      description = "OIDC client secret";
      default = ./_secrets/client_secret.age;
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

    age.secrets = {
      ${secretKey} = lib.mkIf (builtins.isPath cfg.key) {
        rekeyFile = cfg.key;
        owner = cfgSysNgx.user;
        group = cfgSysNgx.group;
      };
      ${secretClientId} = lib.mkIf (builtins.isPath cfg.clientId) {
        rekeyFile = cfg.clientId;
        owner = cfgSysNgx.user;
        group = cfgSysNgx.group;
      };
      ${secretClientSecret} = lib.mkIf (builtins.isPath cfg.clientSecret) {
        rekeyFile = cfg.clientSecret;
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
          if builtins.isPath cfg.key then "file ${config.age.secrets.${secretKey}.path}" else "raw ${cfg.key}"
        };
        endgame_client_id ${
          if builtins.isPath cfg.clientId then
            "file ${config.age.secrets.${secretClientId}.path}"
          else
            "raw ${cfg.clientId}"
        };
        endgame_client_secret ${
          if builtins.isPath cfg.clientSecret then
            "file ${config.age.secrets.${secretClientSecret}.path}"
          else
            "raw ${cfg.clientSecret}"
        };
        endgame_discovery_url ${cfg.discoveryUrl};
        endgame_session_domain ${cfgNgx.baseHost};
        endgame_session_ttl ${cfg.sessionTtl};
        endgame_client_callback_url https://${cfg.hostName}.${cfgNgx.baseHost}/callback;
      '';

      package = pkgs.nginx.override (prev: {
        modules = prev.modules ++ [
          endgame.module
          # Needed for the redirect `set_unescape_uri`
          pkgs.nginxModules.develkit
          pkgs.nginxModules.set-misc
        ];
      });
    };
  };

  imports = (util.nginx path config).server {
    name = "auth";
    # TODO: Consider prettier global error pages
    extraConfig = domain: ''
      endgame_session_domain ${domain};
      endgame_client_callback_url https://${cfg.hostName}.${domain}/callback;
    '';
    locations = {
      "= /logout" = domain: {
        extraConfig = ''
          add_header Set-Cookie 'endgame=;Path=/;Domain=${domain};Max-Age=0;Secure;HttpOnly;SameSite=lax';

          if ($arg_redirect ~ .+) {
            set_unescape_uri $decoded_url $arg_redirect;
            return 302 $decoded_url;
          }

          default_type text/plain;
          return 200 'Logged Out';
        '';

      };

      "= /login" = {
        extraConfig = ''
          endgame on;
          endgame_auto_login on;
          endgame_redirect here redirect;
          try_files /nonexistent @finalize;
        '';
      };

      "= /reset" = domain: {
        extraConfig = ''
          endgame reset;
          endgame_redirect https://${cfg.hostName}.${domain}/login redirect;
        '';
      };

      "@finalize" = {
        extraConfig = ''
          if ($arg_redirect ~ .+) {
            set_unescape_uri $decoded_url $arg_redirect;
            return 302 $decoded_url;
          }

          default_type text/plain;
          return 200 'Logged In';
        '';
      };

      "= /callback" = {
        extraConfig = "endgame callback;";
      };
    };
  };

}
