{
  system = "aarch64-darwin";
  module =
    {
      config,
      ...
    }:
    {
      celo = {
        profiles = {
          system.enable = true;
        };

        modules = {
          core = {
            agenix = {
              identityPath = "${config.celo.modules.core.user.homeDirectory}/.ssh/id_ed25519";
            };
            system = {
              timeZone = "Europe/Amsterdam";
              stateVersion = 5;
            };
          };
          programs = {
            # TODO
            coreutils.enable = true;
            simpalt = {
              # TODO
              enable = true;
              symbol = "⏾";
            };
            # TODO
            git.enable = true;
            # TODO
            zsh.enable = true;
            # TODO
            nali.enable = true;
            # TODO
            neovim.enable = true;
            # TODO
            curl.enable = true;
            # TODO
            bat.enable = true;
            # TODO
            jq.enable = true;
            # TODO
            lazygit.enable = true;
            # TODO
            rage.enable = true;
            # TODO
            rg.enable = true;
            # TODO
            xxd.enable = true;
            # TODO
            delta.enable = true;
            # TODO
            fd.enable = true;
            # TODO
            fzf.enable = true;
            # TODO
            zoxide.enable = true;
            # TODO
            direnv.enable = true;
            # TODO
            tmux.enable = true;
            # TODO
            skull.enable = true;
            # TODO
            ui.alacritty = {
              enable = true;
              tmuxStart = true;
            };
            # TODO
            ui.fonts.hack.enable = true;
            # TODO
            pstree.enable = true;
          };
          services = {
            # TODO
            ssh = {
              enable = true;
              listen = false;
            };
          };
        };
      };
    };
}
