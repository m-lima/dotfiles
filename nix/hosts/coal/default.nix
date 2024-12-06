id: {
  system = "x86_64-linux";
  host = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      hostId = id;

      profiles = {
        base.enable = true;
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
        };
      };
    };
  };
}
