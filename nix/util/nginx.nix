{
  lib,
  mkPath,
  getOptions,
}:
path: config:
let
  cfg = getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;
  endgameIsActive = if builtins.isBool cfg.endgame then cfg.endgame else true;
  endgameExtraConfig =
    autoLogin:
    let
      endgameFlag = if endgameIsActive then "on" else "off";
      autoLoginFlag = if autoLogin then "on" else "off";
    in
    ''
      endgame ${endgameFlag};
      endgame_auto_login ${autoLoginFlag};
    ''
    + (lib.optionalString (
      builtins.isList cfg.endgame && builtins.length cfg.endgame > 0
    ) "endgame_whitelist ${builtins.concatStringsSep " " cfg.endgame};");

  baseServer = name: endgame: extraConfig: locations: {
    options = mkPath path (
      {
        hostName = lib.mkOption {
          type = lib.types.nullOr lib.types.singleLineStr;
          default = name;
          description = "Hostname to expose this service through nginx";
        };

        tls = lib.mkEnableOption "TLS through nginx reverse proxy" // {
          default = cfgNgx.tls;
        };
      }
      // lib.optionalAttrs (!builtins.isNull endgame) {
        endgame = lib.mkOption {
          type = lib.types.either lib.types.bool (lib.types.listOf lib.types.singleLineStr);
          description = "Whether to restrict access with endgame. If strings are passed, they are interpreted as whitelisted emails with access.";
          default = endgame;
          example = [ "email@domain.com" ];
        };
      }
    );

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.services.nginx.enable;
          message = "Nginx needs to be enabled to serve ${name}";
        }
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
      ]
      ++ (lib.optional (!builtins.isNull endgame) {
        assertion = endgameIsActive -> config.celo.modules.servers.endgame.enable;
        message = "Endgame needs to be enabled to serve a private location";
      });

      services.nginx = lib.mkIf (cfg.hostName != null) {
        virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
          forceSSL = cfg.tls;
          enableACME = cfgNgx.enableAcme;
          http2 = true;
          http3 = true;

          locations = lib.mkAfter locations;
        }
        // lib.optionalAttrs (!builtins.isNull extraConfig) {
          extraConfig = lib.mkAfter extraConfig;
        };
      };
    };
  };
in
{
  endgame = {
    isActive = endgameIsActive;
    extraConfig = endgameExtraConfig;
  };
  server =
    {
      name,
      extras ? [ ],
      locations ? { },
      endgame ? null,
      extraConfig ? null,
    }:
    let
      extraOptions = map (e: { inherit (e) options; }) (
        builtins.filter (builtins.hasAttr "options") extras
      );
      extraLocations = lib.mergeAttrsList (
        map (e: e.locations) (builtins.filter (builtins.hasAttr "locations") extras)
      );
      actualLocations =
        if builtins.isFunction locations then locations extraLocations else extraLocations // locations;
    in
    [ (baseServer name endgame extraConfig actualLocations) ] ++ extraOptions;
  extras = {
    proxy =
      {
        port,
        proxyPath ? "/",
        location ? "/",
        proxySettings ? true,
        ws ? false,
        endgame ? false,
        autoLogin ? false,
        extraConfig ? null,
      }:
      {
        options = mkPath path {
          port = lib.mkOption {
            type = lib.types.port;
            description = "Port to serve from";
            default = port;
          };
        };

        locations = {
          ${location} = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}${proxyPath}";
            recommendedProxySettings = proxySettings;
            proxyWebsockets = ws;
            extraConfig =
              (if builtins.isNull extraConfig then "" else extraConfig)
              + (lib.optionalString endgame (endgameExtraConfig autoLogin));
          };
        };
      };
    serve =
      {
        root,
        location ? "/",
        endgame ? false,
        autoLogin ? true,
        extraConfig ? null,
      }:
      {
        options = mkPath path {
          root = lib.mkOption {
            type = lib.types.singleLineStr;
            default = root;
            description = "Base path for statically serving the service";
          };

          index = lib.mkOption {
            type = lib.types.singleLineStr;
            default = "index.html";
            description = "Index file to serve";
          };
        };

        locations = {
          ${location} = {
            root = cfg.root;
            index = cfg.index;
            tryFiles = "$uri /${cfg.index}";
            extraConfig =
              (if builtins.isNull extraConfig then "" else extraConfig)
              + (lib.optionalString endgame (endgameExtraConfig autoLogin));
          };
        };
      };
  };
}
