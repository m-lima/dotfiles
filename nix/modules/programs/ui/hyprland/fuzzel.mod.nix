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
      xdg.dataFile."hypr/power.sh" = {
        text = ''
          #!/usr/bin/env bash

          case $(fuzzel -d -p "" -l 4 <<EOF
           Sleep
           Logoff
           Poweroff
           Reboot
          EOF
          ) in
            ' Sleep') systemctl suspend ;;
            ' Logoff') hyprctl dispatch exit ;;
            ' Poweroff') systemctl poweroff ;;
            ' Reboot') systemctl reboot ;;
          esac
        '';
        executable = true;
      };

      programs = {
        fuzzel = {
          enable = true;
          settings = {
            main = {
              use-bold = true;
              tabs = 4;
              icon-theme = "breeze";
              horizontal-pad = cfg.size.gap.outer;
              vertical-pad = cfg.size.gap.outer;
            };
            colors = {
              background = "${cfg.color.background}ff";
              text = "${cfg.color.foreground}ff";
              prompt = "${cfg.color.accent_alt}ff";
              placeholder = "${cfg.color.accent_alt}ff";
              input = "${cfg.color.foreground}ff";
              match = "${cfg.color.accent}ff";
              selection = "${cfg.color.background_dark}ff";
              selection-text = "${cfg.color.foreground}ff";
              selection-match = "${cfg.color.accent}ff";
              border = "${cfg.color.background_dark}ff";
            };
            border = {
              radius = cfg.size.border.radius;
            };
          };
        };
      };
    };
  };
}
