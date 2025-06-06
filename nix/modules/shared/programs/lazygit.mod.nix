path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
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

      programs = lib.mkIf celo.programs.zsh.enable {
        zsh.initContent = builtins.readFile /${rootDir}/../zsh/config/programs/lazygit.zsh;
      };
    };
  };
}
