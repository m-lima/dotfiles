{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        nixos.enable = true;
        base.enable = true;
        creation.enable = true;
        dev.enable = true;
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
          dropbear.enable = true;
          nixos = {
            timeZone = "Europe/Amsterdam";
            stateVersion = "24.05";
          };
        };
        hardware = {
          bluetooth.enable = true;
          sound = {
            enable = true;
            persist = true;
          };
          wifi.enable = true;
        };
        services = {
          mdns.enable = true;
        };
        programs = {
          simpalt = {
            symbol = "₵";
          };
          skull.enable = true;
          ui = {
            alacritty = {
              tmuxStart = true;
            };
            kde = {
              enable = true;
              insomnia = true;
            };
          };
        };
      };
    };
  };
}
