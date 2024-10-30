{
  config,
  mkUiIf,
  mkDisableOption,
  ...
}:
let
  cfg = config.modules.ui.hardware.sound;
in {
  options = {
    modules.ui.hardware.sound = {
      enable = mkDisableOption "pipewire daemon";
    };
  };

  config = mkUiIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
