{
  lib,
  mkPath,
  getOptions,
}:
path: config: mode:
let
  cfg = getOptions path config;
  cfgNgx = config.celo.modules.servers.nginx;
  defaultServer =
    locations:
    lib.mkIf cfg.enable {
      services.nginx = lib.mkIf (cfg.hostName != null) {
        virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
          forceSSL = cfg.tls;
          enableACME = cfg.tls;
          http2 = true;
          http3 = true;

          inherit locations;
        };
      };
    };
  base = name: {
    options = mkPath path {
      hostName = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = name;
        description = "Hostname to expose this service through nginx";
      };

      tls = lib.mkEnableOption "TLS through nginx reverse proxy" // {
        default = cfgNgx.enableAcme;
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
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
      ];
    };
  };
  optionPort = port: {
    options = mkPath path {
      port = lib.mkOption {
        type = lib.types.port;
        description = "Port to serve from";
        default = port;
      };
    };
  };
  optionServe = root: {
    options = mkPath path {
      root = lib.mkOption {
        type = lib.types.singleLineStr;
        default = root;
        description = "Base path for the service";
      };

      index = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "index.html";
        description = "Index file to serve";
      };
    };
  };
in
if mode == "minimal" then
  {
    name,
    locations ? { },
  }:
  [
    (base name)
    { config = defaultServer locations; }
  ]
else if mode == "expose" then
  {
    name,
    port,
  }:
  [
    (base name)
    (optionPort port)
    {
      config = defaultServer {
        "/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          recommendedProxySettings = true;
        };
      };
    }
  ]
else if mode == "serve" then
  {
    root,
    name,
  }:
  [
    (base name)
    (optionServe root)
    {
      config = defaultServer {
        "/" = {
          root = cfg.root;
          index = cfg.index;
          tryFiles = "$uri /${cfg.index}";
        };
      };
    }
  ]
else if mode == "api" then
  {
    name,
    root,
    port,
    api ? "~ ^/api/(.*)$",
  }:
  [
    (base name)
    (optionPort port)
    (optionServe root)
    {
      options = mkPath path {
        api = lib.mkOption {
          type = lib.types.singleLineStr;
          default = api;
          description = "Path to serve the api from";
        };
      };

      config = defaultServer {
        ${cfg.api} = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}/$1$is_args$args";
          recommendedProxySettings = true;
        };

        "/" = {
          root = cfg.root;
          index = cfg.index;
          tryFiles = "$uri /${cfg.index}";
        };

      };
    }
  ]
else
  builtins.abort "Unknown mode: ${mode}"
