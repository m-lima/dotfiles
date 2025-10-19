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
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/rtor";
      description = "Base path for rtor";
    };

    peerPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      description = "Set peer port and open it in the firewall";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    services.rtorrent = {
      enable = true;
      port = lib.mkIf (cfg.peerPort != null) cfg.peerPort;
      openFirewall = cfg.peerPort != null;
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [ cfg.home ];
    };
  };
}
