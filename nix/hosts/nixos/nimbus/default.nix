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
          nixos.enable = true;
          base.enable = true;
          core.enable = true;
        };

        modules = {
          core = {
            disko = {
              device = "/dev/sda";
              legacy = true;
              luks = true;
              swap = "8G";
            };
            dropbear = {
              enable = true;
              port = builtins.head ((util.rageSecret config ./secrets/core/dropbear/port.age) ++ [ 22 ]);
            };
            nixos = {
              timeZone = "Europe/Amsterdam";
              stateVersion = "24.05";
            };
            user = {
              userName = "kinto";
              motd = ''
                [34m     _       _
                 ___|_|_____| |_ _ _ ___
                |   | |     | . | | |_ -|
                |_|_|_|_|_|_|___|___|___|
                [m'';
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
