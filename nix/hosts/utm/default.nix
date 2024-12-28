{
  system = "aarch64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        minimal.enable = true;
        base.enable = true;
        dev.enable = true;
      };

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
        services = {
          mdns.enable = true;
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
