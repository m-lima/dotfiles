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
      home.packages = with pkgs; [ playerctl ];

      xdg.dataFile = {
        "hypr/player.sh" = {
          text = ''
            #!/usr/bin/env bash

            case $(playerctl -p playerctld status 2> /dev/null) in
              "Playing") status="" ;;
              "Paused") status="" ;;
            esac

            if [ -n "$status" ]; then
              name="$(playerctl -p playerctld metadata -f '{{title}} - {{artist}}' | sed 's/&/&amp;/; s/</&lt;/; s/>/&gt;/; s/\"/&quot;/')"
              echo "{\"text\":\"$status\",\"alt\":\"$name\"}";
            fi
          '';
          executable = true;
        };
      };
    };
  };
}
