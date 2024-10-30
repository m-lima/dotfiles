{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.base.hardware.wireless;
in {
  options = {
    modules.base.hardware.wireless = {
      enable = lib.mkEnableOption "wireless support via wpa_supplicant";
    };
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
