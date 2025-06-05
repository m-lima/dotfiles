{
  system = "x86_64-linux";
  module = {
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
              "~/code/yo" = {
                user = {
                  email = "some@email.com";
                  name = "somename";
                  username = "some-user";
                };
              };
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
          };
        };
      };
    };
  };
}
