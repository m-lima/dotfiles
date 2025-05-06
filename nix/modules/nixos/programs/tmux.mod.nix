path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  playerctl = config.celo.modules.programs.playerctl;
in
{
  config = lib.mkIf cfg.enable (
    util.mkPath path {
      currentlyPlaying = lib.mkIf playerctl.enable ''
        for p in $(playerctl -l); do
          case $(playerctl -p "$p" status 2> /dev/null) in
            "Playing")
              playing=$(playerctl metadata -p "$p" -f '{{title}} - {{artist}}')
              if [ -n "$playing" ]; then
                echo -n " $playing"
                exit
              fi
              ;;
            "Paused")
              if [ -z "$playing" ]; then
                inner_playing=$(playerctl metadata -p "$p" -f '{{title}} - {{artist}}')
                if [ -n "$inner_playing" ]; then
                  playing=" $inner_playing"
                fi
              fi
              ;;
          esac
        done

        echo -n "$playing"
      '';
    }
  );
}
