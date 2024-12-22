{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        base.enable = true;
        creation.enable = true;
        dev.enable = true;
        kde.enable = true;
        nextcloud.enable = true;
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
          bluetooth.enable = true;
          sound.persist = true;
          wifi.enable = true;
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
              insomnia = true;
            };
          };
        };
      };
    };
  };
}
