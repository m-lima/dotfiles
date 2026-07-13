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
        staticip = {
          enable = true;
          interface = "wlp3s0";
          ip = "10.0.0.11";
          gateway = "10.0.0.1";
        };
        wifi.enable = true;
      };
      servers = {
        nginx = {
          enable = true;
          tls = true;
          baseHost = util.secret.rage.mkIf config ./_secrets/servers/nginx/baseHost.rage;
          proxyProtocol = true;
        };
        endgame = {
          enable = true;
          key = ./_secrets/servers/endgame/key.age;
        };
        jelly = {
          enable = true;
          hardwareAcceleration = "intel-modern";
        };
        grafo.enable = true;
        static.enable = true;
      };
      services = {
        ssh = {
          enable = true;
          extraKeys = [
            {
              private = ./_secrets/services/ssh/cog_id_ed25519.age;
              public = ./_secrets/services/ssh/cog_id_ed25519.pub;
            }
          ];
          extraHosts = {
            "cog.github.com" = {
              HostName = "github.com";
              User = "git";
              IdentityFile = "~/.ssh/cog_id_ed25519";
              IdentitiesOnly = true;
            };
            "titanl titanlt" = {
              HostName = "10.0.0.10";
            };
            "titanlt" = {
              RequestTTY = true;
              RemoteCommand = "tmux new -A";
            };
          };
        };
        mdns.enable = true;
        wifidog = {
          enable = true;
          target = "10.0.0.1";
        };
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
          symbol = "₵";
        };
        skull.enable = true;
        endgame.enable = true;
        ui = {
          kde = {
            enable = true;
            insomnia = true;
            autoLogin = true;
          };
          games = {
            steam.enable = true;
          };
          slack.enable = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = util.secret.rage.mkIf config ./_secrets/core/networking/firewall.rage;
}
