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
