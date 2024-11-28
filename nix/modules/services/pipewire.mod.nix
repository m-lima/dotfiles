path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
