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
      home.packages = with pkgs; [ lazygit ];

      programs = lib.mkIf celo.programs.core.zsh.enable {
        zsh.initExtraFirst = builtins.readFile ../../../zsh/config/programs/lazygit.zsh;
      };
    };
  };
}
