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
  config = lib.mkIf cfg.enable (
    util.mkPath path {
      statusRightExtra = builtins.readFile /${rootDir}/../tmux/script/status/spotify.sh;
    }
  );
}
