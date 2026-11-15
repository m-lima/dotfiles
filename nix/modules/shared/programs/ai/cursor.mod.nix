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
  options = util.mkOptions path {
    rules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.nonEmptyStr lib.types.path);
      default = {
        global = ./rules/global.mdc;
        rust = ./rules/rust.mdc;
      };
    };
  };

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      home = {
        packages = [ pkgs.cursor-cli ];
        file = lib.mapAttrs' (n: v: {
          name = ".cursor/rules/${n}.mdc";
          value = if builtins.isPath v then { source = v; } else { text = v; };
        }) cfg.rules;
      };
    };
  };
}
