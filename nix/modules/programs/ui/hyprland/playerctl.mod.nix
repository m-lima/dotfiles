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

            case $(playerctl -p playerctld status) in
              "Playing") status="" ;;
              "Paused") status="" ;;
            esac

            if [ -n "$status" ]; then
              echo "$status $(playerctl -p playerctld metadata -f '{{trunc(title, 32)}} - {{trunc(artist, 32)}}' | sed 's/&/&amp;/; s/</&lt;/; s/>/&gt;/; s/\"/&quot;/')"
            fi
          '';
          executable = true;
        };
      };
    };
  };
}
