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
  options = util.mkOptions path {
    host = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Host address to bind HTTP server to";
      default = "0.0.0.0";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to serve HTTP pages on";
      default = 3535;
    };
    nameservers = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      description = "DNS resolvers to use as upstream";
      default = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };
    expose = lib.mkEnableOption "opening port 53";
  };

  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      mutableSettings = false;

      host = cfg.host;
      port = cfg.port;
      openFirewall = true;

      settings = {
        dns = {
          upstream_dns = cfg.nameservers;
          bootstrap_dns = cfg.nameservers;
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = false;
          safe_search.enabled = false;
        };

        filters =
          map
            (url: {
              enabled = true;
              url = url;
            })
            [
              # "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
              # "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt"
              # "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
            ];
      };

    };

    networking.firewall = lib.mkIf cfg.expose {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    systemd.tmpfiles.rules = lib.optional config.celo.modules.core.impermanence.enable "d /var/lib/private 0700 root root - -";

    environment.persistence = util.withImpermanence config {
      global.directories = [
        {
          directory = "/var/lib/private/AdGuardHome";
          user = "nobody";
          group = "nogroup";
          mode = "0755";
        }
      ];
    };
  };
}
