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
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        enableLsColors = false;
        shellAliases = { };
        # Will be loaded by our own scripts
        enableCompletion = false;
        interactiveShellInit =
          with builtins;
          ''''
          + readFile /${rootDir}/../zsh/config/base/colors.zsh
          + readFile /${rootDir}/../zsh/config/base/completion.zsh
          + readFile /${rootDir}/../zsh/config/base/history.zsh
          + readFile /${rootDir}/../zsh/config/base/keys.zsh
          + readFile /${rootDir}/../zsh/config/base/misc.zsh
          + readFile /${rootDir}/../zsh/config/programs/ls.zsh;
      };
    };

    users.defaultUserShell = pkgs.zsh;

    environment.persistence = util.withImpermanence config { home.files = [ ".zsh_history" ]; };

    home-manager = util.withHome config {
      programs = {
        zsh = {
          enable = true;

          autosuggestion = {
            enable = true;
            highlight = "fg=blue";
          };

          # TODO: This is repeating stuff from the root to avoid the override from homemanager
          history = {
            ignoreAllDups = true;
            expireDuplicatesFirst = true;
            extended = true;
          };
        };
      };
    };
  };
}
