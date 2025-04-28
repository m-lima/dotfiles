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

    environment.persistence = util.withImpermanence config { home.files = [ ".zsh_history" ]; };
  };
}
