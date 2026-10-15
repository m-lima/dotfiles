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
  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      services.nextcloud-client = {
        enable = true;
      };
    };

    environment.persistence = util.given.impermanence config {
      home.directories = [
        "${xdg.rel "cacheHome"}/Nextcloud"
        "${xdg.rel "configHome"}/Nextcloud"
        "${xdg.rel "dataHome"}/Nextcloud"
        "CeloCloud"
      ];
    };
  };
}
