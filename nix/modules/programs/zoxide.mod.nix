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
      home.packages = with pkgs; [ zoxide ];

      programs = lib.mkIf celo.programs.core.zsh.enable {
        zsh.initExtra = builtins.readFile ../../../zsh/config/programs/zoxide.zsh;
      };
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [ ".local/share/zoxide" ];
    };
  };
}
