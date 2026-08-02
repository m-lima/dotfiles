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
        global = ./global.mdc;
        rust = ./rust.mdc;
      };
    };
  };

  config = util.enforceHome path config cfg.enable {
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
