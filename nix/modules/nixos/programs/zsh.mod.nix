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
  cfg = util.getOptions path config;
  home = config.celo.modules.core.home;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        # This is overriden in the default configuration
        enableLsColors = false;
        shellAliases = {
          cpwd = ''${pkgs.oscclip}/bin/osc-copy "$PWD"'';
          ppwd = ''cd "$(${pkgs.oscclip}/bin/osc-paste)"'';
          cbcp = "${pkgs.oscclip}/bin/osc-copy";
          cbpt = "${pkgs.oscclip}/bin/osc-paste";
        };
      };
    };

    users.defaultUserShell = pkgs.zsh;

    environment.persistence = util.withImpermanence config {
      # Only home-manager sets this path
      home = lib.mkIf home.enable {
        directories = [
          ".local/share/zsh"
        ];
      };
    };
  };
}
