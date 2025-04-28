path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
  simpalt = {
    pkg = inputs.simpalt.packages.${pkgs.system}.default;
    zsh = inputs.simpalt.lib.${pkgs.system}.zsh;
  };
in
{
  options = util.mkOptions path {
    symbol = lib.mkOption {
      description = "Symbol to identify the host in the prompt";
      example = "₵";
      type = lib.types.str;
    };
  };

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [ simpalt.pkg ];

      programs = lib.mkIf celo.programs.zsh.enable {
        # TODO: Make this a module in simpalt
        zsh.initExtra = simpalt.zsh {
          symbol = cfg.symbol;
          toggleBinding = "^T";
        };
      };
    };
  };
}
