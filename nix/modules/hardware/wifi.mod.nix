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
      # TDOO: Don't assume impermanence
      secretsFile = "/persist/secrets/wifi.env";
      # TODO: Use ragenix
      networks = {
        "CIA Surveillance Van" = {
          pskRaw = "ext:PSK_RAW";
        };
      };
    };
  };
}
