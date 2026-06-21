{
  lib,
  mkPath,
  mkSecretPath,
  getOptions,
}:
path: config:
let
  cfg = getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;

  isEndgameActive = option: option.enable != null && option.enable;
  mkEndgameExtraConfig =
    option: name:
    builtins.concatStringsSep "\n" [
      (lib.optionalString (option.enable != null) (
        if option.enable then "endgame on;" else "endgame off;"
      ))
      (lib.optionalString (option.autoLogin != null) (
        if option.autoLogin then "endgame_auto_login on;" else "endgame_auto_login off;"
      ))
      (lib.optionalString (option.whitelist != null)
        "include ${config.age.secrets.${mkSecretName name}.path};"
      )
    ];
  location = {
    isEndgameActive =
      name: (isEndgameActive cfg.endgame.locations.${name}) || (isEndgameActive cfg.endgame.root);
    mkEndgameExtraConfig = name: mkEndgameExtraConfig cfg.endgame.locations.${name} name;
  };

  mkSecretName =
    name:
    mkSecretPath path (
      cfg.hostName
      + "."
      + (lib.stringAsChars (
        c:
        if c == " " then
          "_"
        else if c == "/" then
          "-"
        else if builtins.match "[a-zA-Z0-9~\.]" c != null then
          c
        else
          "#"
      ) name)
    );

  baseServer =
    # Name of the server [string]
    name:
    # Default endgame configuration [null or see the option definition for the type]
    endgameDefaultVal:
    # Root-level extraConfig for the nginx.conf block [string]
    extraConfig:
    # Location definitions [attrset of (function or attrset)]
    locations: {
      options = mkPath path (
        let
          endgameType = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                description = "Enable endgame enforcement";
                default = null;
              };
              autoLogin = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                description = "Enable endgame auto login";
                default = null;
              };
              whitelist = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                description = ''
                  An agenix encrypted file with the whitelist rules.
                  The format should be `endgame_whitelist user_a "user b" "user_c";`
                '';
                default = null;
              };
            };
          };
        in
        {
          domain = lib.mkOption {
            type = lib.types.singleLineStr;
            description = "Domain to nest this service behind on nginx";
            default = cfgNgx.baseHost;
            example = "bla.com";
          };

          extraDomains = lib.mkOption {
            type = lib.types.listOf lib.types.singleLineStr;
            description = "Extra domains to nest this service behind on nginx";
            default = [ ];
            example = [
              "bla.com"
              "foo.bar"
            ];
          };

          hostName = lib.mkOption {
            type = lib.types.nullOr lib.types.singleLineStr;
            default = name;
            description = "Hostname to expose this service through nginx";
          };

          tls = lib.mkEnableOption "TLS through nginx reverse proxy" // {
            default = cfgNgx.tls;
          };

          endgame = {
            root = lib.mkOption (
              {
                type = endgameType;
                description = "Endgame configuration for the domain";
              }
              // (lib.optionalAttrs (endgameDefaultVal != null) { default = endgameDefaultVal; })
            );
            locations = builtins.mapAttrs (
              _: v:
              let
                l = if builtins.isFunction v then v "" else v;
              in
              lib.mkOption (
                {
                  type = endgameType;
                  description = "Endgame configuration override for a specific location";
                }
                // (lib.optionalAttrs (builtins.hasAttr "endgame" l && l.endgame != null) {
                  default = l.endgame;
                })
              )
            ) locations;
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
        ++ lib.flatten (
          map (l: [
            {
              assertion = l.enable == true -> config.celo.modules.servers.endgame.enable;
              message = "Endgame needs to be enabled to serve a private location";
            }
            {
              assertion = l.whitelist != null -> lib.strings.hasSuffix ".age" l.whitelist;
              message = "The endgame path must point to an agenix encrypted `.age` file";
            }
          ]) ((builtins.attrValues cfg.endgame.locations) ++ [ cfg.endgame.root ])
        );

        age.secrets = {
          ${mkSecretName "root"} =
            lib.mkIf (isEndgameActive cfg.endgame.root && cfg.endgame.root.whitelist != null)
              {
                rekeyFile = cfg.endgame.root.whitelist;
                owner = "nginx";
                group = "nginx";
              };
        }
        // (builtins.listToAttrs (
          map
            (l: {
              name = mkSecretName l;
              value = {
                rekeyFile = cfg.endgame.locations.${l}.whitelist;
                owner = "nginx";
                group = "nginx";
              };
            })
            (
              builtins.filter (l: location.isEndgameActive l && cfg.endgame.locations.${l}.whitelist != null) (
                builtins.attrNames cfg.endgame.locations
              )
            )
        ));

        services.nginx = lib.mkIf (cfg.hostName != null) {
          virtualHosts = lib.mergeAttrsList (
            map (d: {
              "${cfg.hostName}.${d}" = {
                forceSSL = cfg.tls;
                enableACME = cfgNgx.tls;
                http2 = true;
                http3 = true;
                locations = builtins.mapAttrs (
                  k: v:
                  let
                    base = if builtins.isFunction v then v d else v;
                  in
                  (builtins.removeAttrs base [ "endgame" ])
                  // {
                    extraConfig = builtins.concatStringsSep "\n" [
                      base.extraConfig
                      (location.mkEndgameExtraConfig k)
                    ];
                  }
                ) locations;
                extraConfig = lib.mkAfter (
                  "try_files /nonexistent =444;"
                  + (mkEndgameExtraConfig cfg.endgame.root "root")
                  + (if builtins.isFunction extraConfig then extraConfig d else extraConfig)
                );
              };
            }) ([ cfg.domain ] ++ cfg.extraDomains)
          );
        };
      };
    };
in
{
  server =
    {
      name,
      extras ? [ ],
      locations ? { },
      extraConfig ? "",
      # Default endgame configuration for the root [null or see the option definition for the type]
      endgame ? null,
    }:
    let
      options = lib.mergeAttrsList (
        map (e: e.options) (builtins.filter (builtins.hasAttr "options") extras)
      );
      extraLocations = lib.mergeAttrsList (
        map (e: e.locations) (builtins.filter (builtins.hasAttr "locations") extras)
      );
      actualLocations =
        if builtins.isFunction locations then locations extraLocations else extraLocations // locations;
    in
    [
      (baseServer name endgame extraConfig actualLocations)
      { options = mkPath path options; }
    ];
  extras = {
    proxy =
      {
        socket,
        proxyPath ? "",
        location ? "/",
        proxySettings ? true,
        ws ? false,
        extraConfig ? null,
        # Default endgame configuration for the location [null or see the option definition for the type]
        endgame ? null,
      }:
      {
        inherit endgame;

        options = {
          socket = lib.mkOption {
            type = lib.types.either lib.types.port lib.types.singleLineStr;
            description = "Port to serve from or path to unix socket";
            default = socket;
          };
        };

        locations = {
          ${location} = {
            inherit endgame;
            proxyPass =
              if builtins.isString cfg.socket then
                "http://${cfg.socket}:/${proxyPath}"
              else
                "http://127.0.0.1:${toString cfg.socket}/${proxyPath}";
            recommendedProxySettings = proxySettings;
            proxyWebsockets = ws;
            extraConfig = if builtins.isNull extraConfig then "" else extraConfig;
          };
        };
      };
    serve =
      {
        root,
        location ? "/",
        extraConfig ? null,
        # Default endgame configuration for the location [null or see the option definition for the type]
        endgame ? null,
      }:
      {
        options = {
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
            inherit endgame;
            root = cfg.root;
            index = cfg.index;
            tryFiles = "$uri /${cfg.index}";
            extraConfig = if builtins.isNull extraConfig then "" else extraConfig;
          };
        };
      };
  };
}
