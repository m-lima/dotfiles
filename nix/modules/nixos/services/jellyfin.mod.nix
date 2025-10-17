path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/jellyfin";
      description = "Base path for Jellyfin";
    };

    tls = lib.mkEnableOption "TLS through nginx reverse proxy";

    hostName = lib.mkOption {
      type = lib.types.nullOr lib.types.singleLineStr;
      description = "FQDN for jellyfin";
    };

    hardwareAcceleration = lib.mkOption {
      type = lib.types.enum [
        "none"
        "intel-modern"
      ];
      default = "none";
      description = "Enable hardware acceleration";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tls -> cfg.hostName != null;
        message = "Need to specify a hostName to have TLS termination";
      }
      {
        assertion = cfg.tls -> config.services.nginx.enable;
        message = "Need to enable nginx to have TLS termination";
      }
    ];

    hardware = lib.mkIf (cfg.hardwareAcceleration == "intel-modern") {
      graphics = {
        enable = true;

        extraPackages = with pkgs; [
          intel-ocl
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];
      };
    };

    environment.systemPackages = [
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];

    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
        cacheDir = "${cfg.home}/cache";
        configDir = "${cfg.home}/config";
        dataDir = "${cfg.home}/data";
        logDir = "${cfg.home}/log";
      };

      nginx = lib.mkIf (cfg.hostName != null) {
        virtualHosts."${cfg.hostName}.${config.celo.modules.services.nginx.baseHost}" = {
          forceSSL = cfg.tls;
          enableACME = cfg.tls;

          extraConfig = builtins.concatStringsSep "\n" [
            # The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
            ''client_max_body_size 20M;''
            # Content Security Policy
            # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
            # Enforces https content and restricts JS/CSS to origin
            # External Javascript (such as cast_sender.js for Chromecast) must be whitelisted.
            ''add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";''

          ];

          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:8096";
              recommendedProxySettings = true;
              extraConfig = "proxy_buffering off;";
            };
            "/socket" = {
              proxyPass = "http://127.0.0.1:8096";
              recommendedProxySettings = true;
              proxyWebsockets = true;
            };
          };
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [ cfg.home ];
    };
  };
}
