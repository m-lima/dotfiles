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
  xdg = util.xdg config;
in
{
  options = util.mkOptions path {
    rules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.nonEmptyStr lib.types.path);
      default = {
        rust = ./rules/rust.mdc;
      };
    };
  };

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      programs.claude-code = {
        enable = true;
        configDir = "${xdg.raw.configHome}/claude";
        rules = cfg.rules;
      };
    };
  };
}
