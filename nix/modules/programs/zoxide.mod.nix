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
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        zoxide
      ];

      programs = util.mkIfProgram config "zsh" {
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