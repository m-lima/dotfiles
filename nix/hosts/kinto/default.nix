{
  system = "x86_64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        base.enable = true;
      };

      modules = {
        core = {
          disko = {
            device = "/dev/sda";
            # luks = true;
            swap = "8G";
          };
          nixos = {
            timeZone = "Europe/Amsterdam";
          };
        };
        programs = {
          simpalt = {
            symbol = "ɳ";
          };
        };
      };
    };
  };
}
