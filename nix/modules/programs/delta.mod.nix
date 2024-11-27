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
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        delta
      ];

      xdg = lib.mkIf celo.programs.core.git.enable {
        # TODO: Colors are off
        configFile."git/config".text = builtins.readFile ../../../git/config/delta;
      };
    };
  };
}
