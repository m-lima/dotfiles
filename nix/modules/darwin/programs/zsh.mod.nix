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
    home-manager = util.withHome config {
      programs = {
        zsh = {
          # Darwin doesn't have the `shellAliases` option, so we use home-manager
          shellAliases = {
            cpwd = ''echo -n "$PWD" | pbcopy'';
            ppwd = ''cd "$(pbpaste)"'';
            cbcopy = "pbcopy";
            cbpaste = "pbpaste";
          };
        };
      };
    };
  };
}
