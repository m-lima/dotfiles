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
          darwin.enable = true;
          base.enable = true;
          core.enable = true;
          # dev.enable = true;
          # nextcloud.enable = true;
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
