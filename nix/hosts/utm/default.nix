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
              ports = [ 22 ] ++ (util.rageSecret config ./secrets/services/ssh/ports.age);
            };
          };
          programs = {
            core = {
              nali.entries = {
                cd = "~/code";
                df = "~/code/dotfiles";
                nx = "~/code/dotfiles/nix";
              };
            };
            simpalt = {
              symbol = "μ";
            };
          };
        };
      };
    };
}
