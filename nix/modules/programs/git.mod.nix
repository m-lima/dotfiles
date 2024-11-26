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
    environment.systemPackages = with pkgs; [
      git
    ];

    home-manager = util.withHome config {
      home = {
        packages = with pkgs; [
          git
        ];

        file = {
          ".config/git/config" = {
            text = builtins.readFile ../../../git/config/gitconfig;
          };
          ".config/git/ignore" = {
            source = ../../../git/config/ignore;
          };
        };
      };
    };

    programs = util.mkIfProgram config "zsh" {
      zsh.interactiveShellInit = builtins.readFile ../../../zsh/config/programs/git.zsh;
    };
  };
}
