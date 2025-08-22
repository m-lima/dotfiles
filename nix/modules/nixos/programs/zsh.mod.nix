path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  home = config.celo.modules.core.home;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        # This is overriden in the default configuration
        enableLsColors = false;
      };
    };

    users.defaultUserShell = pkgs.zsh;

    environment.persistence = util.withImpermanence config {
      # Only home-manager sets this path
      home = lib.mkIf home.enable {
        directories = [
          ".local/share/zsh"
        ];
      };
    };
  };
}
