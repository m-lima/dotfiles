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
      neovim
    ];

    environment.etc = {
      "xdg/nvim/init.vim".text = with builtins; ''''
          + readFile ../../../../vim/config/base/options.vim
          + readFile ../../../../vim/config/nvim/options.vim
          + readFile ../../../../vim/config/base/mapping.vim
          + readFile ../../../../vim/config/nvim/mapping.vim;
    };

    home-manager = util.withHome config {
      programs = {
        neovim = {
          enable = true;
        };
      };
    };
  };
}
