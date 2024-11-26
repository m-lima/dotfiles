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
      home = {
        packages = with pkgs; [
          delta
        ];

        file = lib.mkIf celo.programs.core.git.enable {
          # TODO: Colors are off
          ".config/git/config" = {
            text = builtins.readFile ../../../git/config/delta;
          };
        };
      };
    };
  };
}
