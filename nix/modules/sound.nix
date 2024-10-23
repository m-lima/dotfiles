{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.sound;
in {
  options.modules.sound = {
    enable = mkEnableOption "sound";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
