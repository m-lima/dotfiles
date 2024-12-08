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
  config = lib.mkIf cfg.enable {
    home-manager = util.withHome config {
      home.packages = with pkgs; [ bemenu ];

      xdg.dataFile."hypr/power.sh" = {
        text = ''
          #!/usr/bin/env bash

          case $(echo 'Sleep
          Logoff
          Poweroff
          Reboot' | bemenu --prompt "") in
            Sleep) systemctl suspend ;;
            Logoff) hyprctl dispatch exit ;;
            Poweroff) systemctl poweroff ;;
            Reboot ) systemctl reboot ;;
          esac
        '';
        executable = true;
      };

      programs = {
        bemenu = {
          enable = true;
          settings = {
            prompt = "Open";
            ignorecase = true;

            center = true;
            line-height = 28;
            list = "10 down";
            width-factor = 0.3;

            tb = "#${cfg.color.background}";
            tf = "#${cfg.color.accent_alt}";

            fb = "#${cfg.color.background}";
            ff = "#${cfg.color.foreground}";

            nb = "#${cfg.color.background_dark}";
            nf = "#${cfg.color.foreground}";

            ab = "#${cfg.color.background_dark}";
            af = "#${cfg.color.foreground}";

            hb = "#${cfg.color.background_dark}";
            hf = "#${cfg.color.accent}";
          };
        };
      };
    };
  };
}
