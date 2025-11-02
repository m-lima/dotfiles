{
  system = "x86_64-linux";
  module =
    {
      lib,
      pkgs,
      config,
      util,
      ...
    }:
    {
      imports = [ ./hardware-configuration.nix ];

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud31;
        hostName = "cloud";
        https = true;
        configureRedis = true;

        database.createLocally = true;
        config = {
          dbtype = "pgsql";
          adminpassFile = "/path/to/admin-pass-file";
        };

        settings = util.secret.rageOr config ./_secrets/services/nextcloud/smtpSettings.rage { };
      };

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
              port = util.secret.rageOr config ./_secrets/core/dropbear/port.rage 22;
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
            nginx = {
              enable = true;
              tls = true;
              baseHost = util.secret.rageOptional config ./_secrets/services/nginx/baseHost.rage;
              acmeEmail = util.secret.rageOptional config ./_secrets/services/nginx/acmeEmail.rage;
            };
            passer.enable = true;
            ssh = {
              enable = true;
              ports = util.secret.rage config ./_secrets/services/ssh/ports.rage;
              security = "sshguard";
            };
          };
          programs = {
            direnv.enable = true;
            flakerpl.enable = true;
            simpalt = {
              symbol = "ɳ";
            };
          };
        };
      };
    };
}
