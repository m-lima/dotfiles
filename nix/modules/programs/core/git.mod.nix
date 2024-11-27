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
    environment.systemPackages = with pkgs; [
      git
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        git
      ];

      xdg.configFile = {
        "git/config".text = builtins.readFile ../../../../git/config/gitconfig;
        "git/ignore".text = builtins.readFile ../../../../git/config/ignore;
      };
    };

    programs = lib.mkIf celo.programs.core.zsh.enable {
      zsh.interactiveShellInit = builtins.readFile ../../../../zsh/config/programs/git.zsh;
    };
  };
}
