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
    celo.modules.programs.playerctl.enable = true;
    home-manager = {
      xdg.dataFile = {
        "hypr/player.sh" =
          let
            exec = "${pkgs.playerctl}/bin/playerctl";
          in
          {
            text = ''
              #!${pkgs.bash}/bin/bash

              case $(${exec} -p playerctld status 2> /dev/null) in
                "Playing") status="" ;;
                "Paused") status="" ;;
              esac

              if [ -n "$status" ]; then
                name="$(${exec} -p playerctld metadata -f '{{title}} - {{artist}}' | sed 's/&/&amp;/; s/</&lt;/; s/>/&gt;/; s/\"/&quot;/')"
                echo "{\"text\":\"$status\",\"alt\":\"$name\"}";
              fi
            '';
            executable = true;
          };
      };
    };
  };
}
