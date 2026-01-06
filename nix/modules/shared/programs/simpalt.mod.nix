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
    pkg = inputs.simpalt.packages.${pkgs.stdenv.hostPlatform.system}.default;
    zsh = inputs.simpalt.lib.zsh;
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
    assertions = [
      {
        assertion = celo.programs.zsh.enable;
        message = "simpalt enabled without zsh";
      }
    ];

    home-manager = {
      home.packages = [ simpalt.pkg ];

      programs = {
        zsh.initContent = simpalt.zsh {
          symbol = cfg.symbol;
          toggleBinding = "^T";
        };
      };
    };
  };
}
