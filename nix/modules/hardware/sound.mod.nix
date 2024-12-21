path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
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
      home.directories = lib.optional cfg.persist ".local/state/wireplumber";
    };
  };
}
