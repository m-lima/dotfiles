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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [ git ];

      xdg.configFile = {
        "git/config".text =
          builtins.readFile /${rootDir}/../git/config/gitconfig
          + (lib.optionalString config.celo.modules.services.ssh.enable (
            builtins.readFile /${rootDir}/../git/config/sign
          ));
        "git/ignore".text = builtins.readFile /${rootDir}/../git/config/ignore;
      };

      programs = lib.mkIf celo.programs.zsh.enable {
        zsh.initExtra = util.extractCompdef (builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh);
      };
    };

    programs = lib.mkIf celo.programs.zsh.enable {
      zsh.interactiveShellInit = builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh;
    };
  };
}
