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
          wakeOnLan = true;
          initrdModules = [ "igb" ];

        };
      };
      servers = {
        nginx =
          let
            host = util.secret.rage.orElse config ./_secrets/servers/nginx/baseHost.rage "";
          in
          {
            enable = true;
            tls = true;
            baseHost = lib.mkIf (host != "") host;
            proxyProtocol = true;
            streams = lib.mkIf (host != "") [
              {
                host = "coal.${host}";
                target = "10.0.0.11";
                proxyProtocol = true;
              }
            ];
          };
        endgame = {
          enable = true;
          key = ./_secrets/servers/endgame/key.age;
        };
        grafo.enable = true;
        static.enable = true;
      };
      services = {
        ipifier = {
          enable = true;
          configuration = ./_secrets/services/ipifier/config.age;
        };
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
            autoLogin = true;
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
