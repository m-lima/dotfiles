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

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome path config) ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [ ripgrep ];

      programs = lib.mkIf celo.programs.core.zsh.enable {
        zsh.initExtraFirst = builtins.readFile ../../../zsh/config/programs/rg.zsh;
      };
    };
  };
}
