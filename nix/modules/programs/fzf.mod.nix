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
      home.packages = with pkgs; [ fzf ];

      programs = {
        fzf = {
          enable = true;
        };

        zsh = lib.mkIf (celo.programs.core.zsh.enable && celo.programs.fd.enable) {
          initExtraFirst = builtins.readFile ../../../zsh/config/programs/fzf_fd.zsh;
        };
      };
    };
  };
}
