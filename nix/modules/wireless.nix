{ ... }:
with lib;
let
  cfg = config.modules.wireless;
in {
  options.modules.sound = {
    enable = mkEnableOption "sound";
  };

  config = mkIf cfg.enable {
    networking = {
      # Enables wireless support via wpa_supplicant.
      wireless = {
        enable = true;
        environmentFile = "/persist/secrets/wireless.env";
        networks = {
          "@SSID@" = {
            psk = "@PSK@";
          };
        };
      };
    };
  };
}
