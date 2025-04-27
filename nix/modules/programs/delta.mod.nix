path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [ delta ];

      xdg = lib.mkIf celo.programs.git.enable {
        # TODO: Colors are off
        configFile."git/config".text = builtins.readFile ../../../git/config/delta;
      };
    };
  };
}
