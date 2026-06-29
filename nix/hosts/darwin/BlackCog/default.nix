{
  config,
  ...
}:
{
  # TODO: Required for now because of agenix
  nixpkgs.hostPlatform = "aarch64-darwin";
  celo = {
    profiles = {
      system.enable = true;
      base.enable = true;
      core.enable = true;
      dev.enable = true;
      kube.enable = true;
      ui.enable = true;
    };

    modules = {
      core = {
        agenix = {
          identityPath = "${config.celo.modules.core.user.homeDirectory}/.ssh/id_ed25519";
        };
        darwin.enable = true;
        home = {
          stateVersion = "26.05";
        };
        system = {
          timeZone = "Europe/Amsterdam";
          stateVersion = 6;
        };
      };
      programs = {
        flakerpl.enable = true;
        nixshell.enable = true;
        simpalt = {
          symbol = "◉";
        };
        nali = {
          entries = {
            cd = "~/code";
            nx = "~/code/dotfiles/nix";
            cg = "~/code/cog";
            mc = "~/Misc";
            dw = "~/Downloads";
            cc = "~/Library/CloudStorage/Nextcloud-marcelo@cloud․mrcelo․com";
          };
        };

        git = {
          overrides = {
            "~/code/cog" = ./_secrets/programs/git/cog.age;
          };
        };

        skull.enable = true;
        endgame.enable = true;

        # NEW
        cursor.enable = true;
        coreutils.enable = true;
        msaler.enable = true;
        nmap.enable = true;
        pstree.enable = true;
        yq.enable = true;

        ui = {
          blank.enable = true;
          slack.enable = true;
        };
      };

      services = {
        ssh = {
          enable = true;
          listen = false;
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
            "coall coallt" = {
              HostName = "10.0.0.11";
            };
            "coallt" = {
              RequestTTY = true;
              RemoteCommand = "tmux new -A";
            };
          };
        };
      };
    };
  };
}
