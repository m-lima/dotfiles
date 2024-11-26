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
          + readFile ../../../../vim/config/options.vim
          + readFile ../../../../vim/config/mapping.vim;
    };
  };
}
