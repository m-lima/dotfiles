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
  criscelo = inputs.criscelo.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options = util.mkOptions path {
    domain = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Domain to nest this service behind on nginx";
      example = "bla.com";
    };
  };

  config = lib.mkIf cfg.enable {
    celo.modules.servers.endgame.extraDomains = lib.mkAfter [ cfg.domain ];
    services = {
      nginx = {
        virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          http2 = true;
          http3 = true;
          extraConfig = ''
            endgame_session_domain ${cfg.domain};
            endgame_client_callback_url https://auth.${cfg.domain}/callback;
          '';

          locations = {
            "/" = {
              root = criscelo;
            };

            "/info" = {
              root = criscelo;
              extraConfig = "endgame on; endgame_auto_login on;";
            };
          };
        };
      };
    };
  };
}
