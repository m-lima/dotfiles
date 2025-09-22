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
    programs.zsh.interactiveShellInit = lib.mkAfter ''
      alias cpwd='echo -n "$PWD" | pbcopy'
      alias ppwd='cd $(pbpaste)'
    '';
  };
}
