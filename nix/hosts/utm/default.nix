id: {
  system = "aarch64-linux";
  host = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      hostId = id;

      profiles.base.enable = true;

      modules = {
        core = {
          disko = {
            device = "/dev/vda";
            swap = "1G";
          };
          nixos = {
            timeZone = "Europe/Amsterdam";
          };
        };
        programs = {
          simpalt = {
            symbol = "μ";
          };
        };
      };
    };
  };
}
