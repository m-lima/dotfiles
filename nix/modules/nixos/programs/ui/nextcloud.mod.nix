path:
{
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      services.nextcloud-client = {
        enable = true;
      };
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "cacheHome"}/Nextcloud"
        "${xdg.rel "configHome"}/Nextcloud"
        "${xdg.rel "dataHome"}/Nextcloud"
        "CeloCloud"
      ];
    };
  };
}
