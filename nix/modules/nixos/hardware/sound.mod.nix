path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
in
{
  options = util.mkOptions path {
    persist = lib.mkEnableOption "sound volume persistance";
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    environment.persistence = util.withImpermanence config {
      home.directories = lib.optional cfg.persist "${xdg.rel "dataHome"}/wireplumber";
    };
  };
}
