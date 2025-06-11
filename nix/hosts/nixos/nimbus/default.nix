{
  system = "x86_64-linux";
  module =
    {
      lib,
      config,
      util,
      ...
    }:
    {
      imports = [ ./hardware-configuration.nix ];

      celo = {
        profiles = {
          system.enable = true;
          base.enable = true;
          core.enable = true;
          disko.enable = true;
        };

        modules = {
          core = {
            agenix = {
              identityPath = "/persist/etc/ssh/ssh_host_ed25519_key";
            };
            disko = {
              device = "/dev/sda";
              legacy = true;
              luks = true;
              swap = "8G";
            };
            dropbear = {
              enable = true;
              port = builtins.head ((util.rageSecret config ./_secrets/core/dropbear/port.rage) ++ [ 22 ]);
            };
            impermanence = {
              retain.user.directories = [
                "code"
                "bin"
                "git"
              ];
            };
            system = {
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
              enable = true;
              ports = util.rageSecret config ./_secrets/services/ssh/ports.rage;
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
