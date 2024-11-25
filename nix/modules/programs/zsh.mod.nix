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
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        enableLsColors = false;
        shellAliases = {};
        interactiveShellInit = with builtins; ''''
          + readFile ../../../zsh/config/base/colors.zsh
          + readFile ../../../zsh/config/base/completion.zsh
          + readFile ../../../zsh/config/base/history.zsh
          + readFile ../../../zsh/config/base/keys.zsh
          + readFile ../../../zsh/config/base/misc.zsh
          + readFile ../../../zsh/config/programs/git.zsh
          + readFile ../../../zsh/config/programs/ls.zsh
          + readFile ../../../zsh/config/programs/nvim.zsh;
      };
    };

    users.defaultUserShell = pkgs.zsh;
  };
}
