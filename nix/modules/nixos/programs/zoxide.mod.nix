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
  config = util.enforceHome path config cfg.enable {
    environment.persistence = util.withImpermanence config {
      home.directories = [ ".local/share/zoxide" ];
    };
  };
}
