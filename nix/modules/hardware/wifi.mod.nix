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
      userControlled.enable = true;
      secretsFile = "/persist/secrets/wifi.env";
      networks = {
        "CIA Surveillance Van" = {
          pskRaw = "ext:PSK_RAW";
        };
      };
    };
  };
}
