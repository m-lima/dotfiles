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
  options = util.mkPath path {
    persist = lib.mkEnableOption "persistence of the `~/creation` directory";
  };

  config = util.enforceHome path config cfg.persist {
    environment.persistence = util.withImpermanence config {
      home.directories = [
        "creation"
      ];
    };
  };
}
