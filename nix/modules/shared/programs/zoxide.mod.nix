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
      home.packages = with pkgs; [ zoxide ];

      programs = lib.mkIf celo.programs.zsh.enable {
        zsh.initExtra = builtins.readFile /${rootDir}/../zsh/config/programs/zoxide.zsh;
      };
    };
  };
}
