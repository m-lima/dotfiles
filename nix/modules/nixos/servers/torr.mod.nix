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
  nginx = util.nginx path config;
  name = "torr";
in
{
  imports = nginx.server {
    inherit name;
    extras = [
      (nginx.extras.proxy {
        socket = cfg.port;
      })
    ];
  };

  options = util.mkOptions path {
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to serve webUI";
      default = 8779;
    };
  };

  config = lib.mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      webuiPort = cfg.port;
      serverConfig = {
        Preferences = {
          WebUI = {
            AlternativeUIEnabled = true;
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            LocalHostAuth = false;
            AuthSubnetWhitelistEnabled = true;
            AuthSubnetWhitelist = "10.0.0.0/8, 100.64.0.0/10";
          };
        };
      };
    };

    users.users = lib.mkIf config.celo.modules.servers.jelly.enable {
      ${config.services.qbittorrent.user}.extraGroups = [
        config.services.jellyfin.group
      ];
    };

    environment.persistence = util.given.impermanence config {
      global.directories = [
        config.services.qbittorrent.profileDir
      ];
    };
  };
}
