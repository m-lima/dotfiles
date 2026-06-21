path:
{
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  endgame = inputs.endgame.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [
        endgame
      ];
    };
  };
}
