path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOption path config;
in {
  options = util.mkModule path {
    description = "wireless support via wpa_supplicant";
  };

  config = lib.mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      environmentFile = "/persist/secrets/wireless.env";
      networks = {
        "@SSID@" = {
          psk = "@PSK@";
        };
      };
    };
  };
}
