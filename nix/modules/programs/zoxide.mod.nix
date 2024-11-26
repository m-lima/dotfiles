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
      {
        assertion = user.home.enable;
        message = "zoxide enabled without home-manager";
      }
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        zoxide
      ];

      programs = lib.mkIf config.celo.modules.programs.zsh.enable {
        zsh.initExtra = builtins.readFile ../../../zsh/config/programs/zoxide.zsh;
      };
    };

    environment.persistence = util.withImpermanence config {
      home.files = [
        ".local/share/zoxide"
      ];
    };
  };
}
