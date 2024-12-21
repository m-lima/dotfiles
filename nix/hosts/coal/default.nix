{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        base.enable = true;
        dev.enable = true;
        kde.enable = true;
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
          sound.persist = true;
        };
        programs = {
          simpalt = {
            symbol = "₵";
          };
          ui = {
            alacritty = {
              tmuxStart = true;
            };
            hyprland = {
              scale = 2.0;
            };
            kde = {
              scale = 1.5;
            };
            gimp.enable = true;
            nextcloud.enable = true;
            spotify.enable = true;
          };
        };
      };
    };
  };
}
