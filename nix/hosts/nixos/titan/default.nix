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
          latest = false;
        };
        memtest.enable = true;
      };
      hardware = {
        bluetooth.enable = true;
        sound = {
          enable = true;
          persist = true;
        };
        staticip = {
          enable = true;
          interface = "enp8s0";
          ip = "10.0.0.10";
          gateway = "10.0.0.1";
          nameservers = [ "127.0.0.1" ];
          wakeOnLan = true;
          initrdModules = [ "igb" ];
        };
      };
      servers = {
        nginx = {
          enable = true;
          baseHost = util.secret.rage.mkIf config ./_secrets/servers/nginx/baseHost.rage;
          bindAddress = "100.64.0.5";
        };
        grafo = {
          enable = true;
          disableAuth = true;
        };
        static.enable = true;
      };
      services = {
        adguard = {
          enable = true;
          expose = true;
        };
        ipifier.enable = true;
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
            "coal coalt" = {
              HostName = "10.0.0.11";
            };
            "coalt" = {
              RequestTTY = true;
              RemoteCommand = "tmux new -A";
            };
          };
        };
        tailscale = {
          enable = true;
          exitNode = true;
        };
      };
      programs = {
        cursor.enable = true;
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
            dw = "~/Downloads";
            cc = "~/CeloCloud";
          };
        };
        playerctl.enable = true;
        skull.enable = true;
        endgame.enable = true;
        zsh.simpalt.symbol = "τ";
        ui = {
          creation = {
            lmms.enable = true;
          };
          ghostty = {
            size = {
              width = 240;
              height = 80;
            };
          };
          kde = {
            enable = true;
            insomnia = true;
            autoLogin = true;
            panelCount = 2;
          };
          games = {
            steam.enable = true;
            minecraft.enable = true;
          };
          rustdesk.enable = true;
          slack.enable = true;
        };
      };
    };
  };

  # Use proprietary Nvidia drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;

    # For GTX 1080 (GP104)
    # Obtained with `lspci | rg VGA`
    # Checked in https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/
    # or searched for on the "All drivers" page
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # Extra firewall rules
  networking.firewall.allowedTCPPorts = util.secret.rage.mkIf config ./_secrets/core/networking/firewall.rage;
}
