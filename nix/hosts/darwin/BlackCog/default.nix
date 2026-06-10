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
            cc = "~/CeloCloud";
          };
        };

        skull.enable = true;
        ui.slack.enable = true;

        # NEW
        coreutils.enable = true;
        nmap.enable = true;
        pstree.enable = true;
        yq.enable = true;
      };

      services = {
        ssh = {
          enable = true;
          listen = false;
          extraHosts = {
            "coall coallt" = {
              hostname = "10.0.0.10";
            };
            "coallt" = {
              RequestTTY = "yes";
              RemoteCommand = "tmux new -A";
            };
          };
        };
      };
    };
  };
}
