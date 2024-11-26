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
      home.packages = with pkgs; [
        ripgrep
      ];

      programs = util.mkIfProgram config "zsh" {
        zsh.initExtraFirst = builtins.readFile ../../../zsh/config/programs/rg.zsh;
      };
    };
  };
}
