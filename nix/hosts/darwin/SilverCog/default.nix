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
            agenix.identityPath = "${config.celo.modules.core.user.homeDirectory}/.ssh/id_ed25519";
          };
          programs = {
            simpalt = {
              symbol = "⏾";
            };
          };
        };
      };
    };
}
