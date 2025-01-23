{
  system = "x86_64-linux";
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
        };

        modules = {
          core = {
            disko = {
              device = "/dev/sda";
              legacy = true;
              # luks = true;
              swap = "8G";
            };
            nixos = {
              timeZone = "Europe/Amsterdam";
            };
            user = {
              userName = "kinto";
            };
          };
          services = {
            ssh = {
              ports = util.rageSecret config ./secrets/services/ssh/ports.age;
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
