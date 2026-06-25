{
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
      ui.enable = true;
    };

    modules = {
      core = {
        disko = {
          device = "/dev/nvme0n1";
          luks = true;
          swap = "8G";
        };
        dropbear.enable = true;
        system = {
          timeZone = "Europe/Amsterdam";
          stateVersion = "26.05";
        };
      };
      hardware = {
        bluetooth.enable = true;
        sound = {
          enable = true;
          persist = true;
        };
      };
      # servers = {
      #   nginx = {
      #     enable = true;
      #     tls = true;
      #     baseHost = util.secret.rage.mkIf config ./_secrets/servers/nginx/baseHost.rage;
      #   };
      #   endgame = {
      #     enable = true;
      #     key = ./_secrets/servers/endgame/key.age;
      #   };
      #   jelly = {
      #     enable = true;
      #     hardwareAcceleration = "intel-modern";
      #   };
      #   grafo.enable = true;
      #   static.enable = true;
      # };
      services = {
        # ipifier = {
        #   enable = true;
        #   configuration = ./_secrets/services/ipifier/config.age;
        # };
        ssh = {
          enable = true;
          extraHosts = {
            "coall coallt" = {
              HostName = "10.0.0.11";
            };
            "coallt" = {
              RequestTTY = true;
              RemoteCommand = "tmux new -A";
            };
          };
        };
        mdns.enable = true;
      };
      programs = {
        flakerpl.enable = true;
        nixshell.enable = true;
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
          symbol = "τ";
        };
        skull.enable = true;
        endgame.enable = true;
        ui = {
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
    interfaces.enp8s0 = {
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
    firewall.allowedTCPPorts = util.secret.rage.mkIf config ./_secrets/core/networking/firewall.rage;
  };
}
