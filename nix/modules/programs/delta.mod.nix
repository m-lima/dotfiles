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

        file = util.mkIfProgram config "git" {
          # TODO: Colors are off
          ".config/git/config" = {
            text = builtins.readFile ../../../git/config/delta;
          };
        };
      };
    };
  };
}
