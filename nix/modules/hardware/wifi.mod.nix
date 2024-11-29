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
  options = util.mkOptions path { description = "WiFi support via wpa_supplicant"; };

  config = lib.mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      environmentFile = "/persist/secrets/wifi.env";
      networks = {
        "@SSID@" = {
          psk = "@PSK@";
        };
      };
    };
  };
}
