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
  xdg = util.xdg config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        # Will be loaded by our own scripts
        enableCompletion = false;
        interactiveShellInit = lib.mkBefore (
          ""
          + builtins.readFile /${rootDir}/../zsh/config/base/colors.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/completion.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/history.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/keys.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/misc.zsh
          + builtins.readFile /${rootDir}/../zsh/config/programs/ls.zsh
        );
      };
    };

    environment.shellAliases = lib.mkForce { };

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
            path = "${xdg.abs "dataHome"}/zsh/history";
          };
        };
      };
    };
  };
}
