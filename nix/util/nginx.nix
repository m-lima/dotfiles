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
    extraConfig: locations:
    lib.mkIf cfg.enable {
      services.nginx = lib.mkIf (cfg.hostName != null) {
        virtualHosts."${cfg.hostName}.${cfgNgx.baseHost}" = {
          forceSSL = cfg.tls;
          enableACME = cfgNgx.enableAcme;
          http2 = true;
          http3 = true;

          extraConfig = lib.mkIf (!builtins.isNull extraConfig) extraConfig;

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
        default = cfgNgx.tls;
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
        description = "Base path for statically serving the service";
      };

      index = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "index.html";
        description = "Index file to serve";
      };
    };
  };
  configServe = {
    "/" = {
      root = cfg.root;
      index = cfg.index;
      tryFiles = "$uri /${cfg.index}";
    };
  };
  optionApi = api: apiPass: {
    options = mkPath path {
      api = lib.mkOption {
        type = lib.types.singleLineStr;
        default = api;
        description = "Path to serve the api from";
      };

      apiPass = lib.mkOption {
        type = lib.types.singleLineStr;
        default = apiPass;
        description = "Path to proxy pass the api";
      };
    };
  };
  optionWs = ws: wsPass: {
    options = mkPath path {
      ws = lib.mkOption {
        type = lib.types.singleLineStr;
        default = ws;
        description = "Path to serve the websocket from";
      };

      wsPass = lib.mkOption {
        type = lib.types.singleLineStr;
        default = wsPass;
        description = "Path to proxy pass to websockets";
      };
    };
  };
  configProxy = location: pass: {
    ${location} = {
      proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}/${pass}";
      recommendedProxySettings = true;
    };
  };
  configApi = configProxy cfg.api cfg.apiPass;
  configWs = {
    ${cfg.ws} = {
      proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}/${cfg.wsPass}";
      proxyWebsockets = true;
    };
  };
in
if mode == "minimal" then
  {
    name,
    locations ? { },
    extraConfig ? null,
  }:
  [
    (base name)
    { config = defaultServer extraConfig locations; }
  ]
else if mode == "expose" then
  {
    name,
    port,
    extraConfig ? null,
  }:
  [
    (base name)
    (optionPort port)
    { config = defaultServer extraConfig (configProxy "/" ""); }
    {
      config = defaultServer extraConfig {
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
    extraConfig ? null,
  }:
  [
    (base name)
    (optionServe root)
    { config = defaultServer extraConfig configServe; }
  ]
else if mode == "api" then
  {
    name,
    root,
    port,
    api ? "~ ^/api/(.*)$",
    apiPass ? "$1$is_args$args",
    extraConfig ? null,
  }:
  [
    (base name)
    (optionPort port)
    (optionServe root)
    (optionApi api apiPass)
    { config = defaultServer extraConfig (configServe // configApi); }
  ]
else if mode == "apiWithWS" then
  {
    name,
    root,
    port,
    api ? "~ ^/api/(.*)$",
    apiPass ? "$1$is_args$args",
    ws ? "~ ^/ws/(.*)$",
    wsPass ? "$1$is_args$args",
    extraConfig ? null,
  }:
  [
    (base name)
    (optionPort port)
    (optionServe root)
    (optionApi api apiPass)
    (optionWs ws wsPass)
    { config = defaultServer extraConfig (configServe // configApi // configWs); }
  ]
else
  builtins.abort "Unknown mode: ${mode}"
