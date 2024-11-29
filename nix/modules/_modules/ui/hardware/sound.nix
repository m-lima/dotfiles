{
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.modules.ui.hardware.sound;
in
{
  options = {
    modules.ui.hardware.sound = {
      enable = util.mkDisableOption "pipewire daemon";
    };
  };

  config = util.mkIfUi config cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
