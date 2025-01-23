{
  system = "aarch64-linux";
  module =
    {
      config,
      util,
      ...
    }:
    {
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
            ssh = {
              ports = [
                22
                (util.rageSecret config ./secrets/ssh_port.age)
              ];
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
