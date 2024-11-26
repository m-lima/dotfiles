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
        fzf
      ];

      programs = {
        fzf = {
          enable = true;
        };

        zsh = util.mkIfProgram config [ "zsh" "fd" ] {
          initExtraFirst = builtins.readFile ../../../zsh/config/programs/fzf_fd.zsh;
        };
      };
    };
  };
}
