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
    home-manager = {
      services.nextcloud-client = {
        enable = true;
      };
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".cache/Nextcloud"
        ".config/Nextcloud"
        ".local/share/Nextcloud"
        "CeloCloud"
      ];
    };
  };
}
