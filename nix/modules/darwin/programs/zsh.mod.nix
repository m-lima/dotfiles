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
        # Enable colors for ls
        interactiveShellInit = "alias ls='ls -G'";
      };
    };
  };
}
