{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.base.hardware.wireless;
in {
  options = {
    modules.base.hardware.wireless = {
      enable = mkEnableOption "wireless support via wpa_supplicant";
    };
  };

  config = mkIf cfg.enable {
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
