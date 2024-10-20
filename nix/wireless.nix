{ ... }: {
  networking = {
    # Enables wireless support via wpa_supplicant.
    # TODO: Move to /persist/secrets/wireless/<env_file>
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
}
