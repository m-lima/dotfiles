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
  cfg = util.getOptions path config;
  simpalt = inputs.simpalt.packages."${pkgs.system}";
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        simpalt.default
      ];

      programs = util.mkIfProgram config "zsh" {
        # TODO: Make computer symbol variable
        # TODO: Make this a module in simpalt
        zsh.initExtra = simpalt.zsh { symbol = "₵"; toggleBinding = "^T"; };
      };
    };
  };
}
