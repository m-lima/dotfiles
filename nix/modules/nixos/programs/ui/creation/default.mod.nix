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

  config = util.given.enforcedHome path config cfg.persist {
    environment.persistence = util.given.impermanence config {
      home.directories = [
        "creation"
      ];
    };
  };
}
