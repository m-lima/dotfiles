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
  simpalt = inputs.simpalt.packages."${pkgs.system}";
in
{
  options = util.mkOptions path {
    symbol = lib.mkOption {
      description = "Symbol to identify the host in the prompt";
      example = "₵";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome config path) ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [ simpalt.default ];

      programs = lib.mkIf celo.programs.core.zsh.enable {
        # TODO: Make this a module in simpalt
        zsh.initExtra = simpalt.zsh {
          symbol = cfg.symbol;
          toggleBinding = "^T";
        };
      };
    };
  };
}
