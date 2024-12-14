{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        base.enable = true;
        dev.enable = true;
        hyprland.enable = true;
        ui.enable = true;
      };

      modules = {
        core = {
          disko = {
            device = "/dev/nvme0n1";
            luks = true;
            swap = "8G";
          };
          nixos = {
            timeZone = "Europe/Amsterdam";
          };
        };
        hardware = {
          wifi.enable = true;
          bluetooth.enable = true;
        };
        programs = {
          simpalt = {
            symbol = "₵";
          };
          ui = {
            hyprland = {
              scale = 2.0;
            };
            spotify.enable = true;
          };
        };
      };
    };
  };
}
