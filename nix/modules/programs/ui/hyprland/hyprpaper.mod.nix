path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.hyprland;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [ hyprpaper ];

      services = {
        hyprpaper = {
          enable = true;
          settings = {
            preload = [ "${cfg.wallpaper}" ];
            wallpaper = [ ",${cfg.wallpaper}" ];
          };
        };
      };

      # Fix for start ordering
      # By default the Unit starts after `graphical-session-pre`
      # However hyprland starts after UWSM and only after `graphical-session`
      # So this manaually sets the service to start after UWSM
      systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
    };
  };
}
