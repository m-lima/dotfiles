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
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = config.celo.modules.hardware.sound.enable;
        message = "Cannot enable playerctl if there is no sound";
      }
    ];

    home-manager = {
      home.packages = with pkgs; [ playerctl ];
    };
  };
}
