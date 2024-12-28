{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        minimal.enable = true;
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
          nixos = {
            timeZone = "Europe/Amsterdam";
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
