path:
{
  lib,
  config,
  util,
  pkgs,
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
        interactiveShellInit =
          with builtins;
          ''''
          + readFile ../../../../zsh/config/base/colors.zsh
          + readFile ../../../../zsh/config/base/completion.zsh
          + readFile ../../../../zsh/config/base/history.zsh
          + readFile ../../../../zsh/config/base/keys.zsh
          + readFile ../../../../zsh/config/base/misc.zsh
          + readFile ../../../../zsh/config/programs/ls.zsh
          + readFile ../../../../zsh/config/programs/nvim.zsh;
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
