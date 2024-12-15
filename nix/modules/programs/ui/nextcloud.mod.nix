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
      # Fix for start ordering
      # By default the Unit starts after `graphical-session-pre`
      # However hyprland starts after UWSM and only after `graphical-session`
      # So this manaually sets the service to start after UWSM
      systemd.user.services.nextcloud-client.Unit.After = lib.mkForce "graphical-session.target";

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
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
