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
          creation.enable = true;
          dev.enable = true;
          disko.enable = true;
          nextcloud.enable = true;
          ui.enable = true;
        };

        modules = {
          core = {
            agenix = {
              identityPath = "/persist/etc/ssh/ssh_host_ed25519_key";
            };
            disko = {
              device = "/dev/nvme0n1";
              luks = true;
              swap = "8G";
            };
            dropbear.enable = true;
            system = {
              timeZone = "Europe/Amsterdam";
              stateVersion = "24.05";
            };
          };
          hardware = {
            bluetooth.enable = true;
            sound = {
              enable = true;
              persist = true;
            };
            wifi.enable = true;
          };
          services = {
            ssh.enable = true;
            mdns.enable = true;
          };
          programs = {
            git = {
              overrides = {
                "~/code/cog" = "cog.age";
              };
            };
            nali = {
              entries = {
                cd = "~/code";
                nx = "~/code/dotfiles/nix";
                cg = "~/code/cog";
              };
            };
            playerctl.enable = true;
            simpalt = {
              symbol = "₵";
            };
            skull.enable = true;
            ui = {
              alacritty = {
                tmuxStart = true;
              };
              firefox = {
                multiAccount = true;
              };
              kde = {
                enable = true;
                insomnia = true;
              };
              slack.enable = true;
              steam.enable = true;
            };
          };
        };
      };

      networking = {
        interfaces.wlp3s0 = {
          ipv4.addresses = [
            {
              address = "10.0.0.10";
              prefixLength = 24;
            }
          ];
          useDHCP = false;
        };
        defaultGateway = "10.0.0.1";
        nameservers = [ "10.0.0.1" ];
        firewall.allowedTCPPorts = builtins.head (
          (util.rageSecret config ./_secrets/core/networking/firewall.rage) ++ [ ]
        );
      };
    };
}
