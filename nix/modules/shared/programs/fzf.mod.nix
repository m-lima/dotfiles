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
      home.packages = with pkgs; [ fzf ];

      programs = {
        fzf = {
          enable = true;
        };

        zsh = lib.mkIf (celo.programs.zsh.enable && celo.programs.fd.enable) {
          initContent = builtins.readFile /${rootDir}/../zsh/config/programs/fzf_fd.zsh;
        };
      };
    };
  };
}
