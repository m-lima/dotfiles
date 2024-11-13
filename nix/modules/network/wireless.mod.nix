path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOpion path config;
in {
  options = util.mkModuleOptionDesc path "wireless support via wpa_supplicant" {};

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
