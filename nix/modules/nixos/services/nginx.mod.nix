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
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

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
        default = {
          default = true;
          extraConfig = "return 444;";
        };
      };
    };
  };
}
