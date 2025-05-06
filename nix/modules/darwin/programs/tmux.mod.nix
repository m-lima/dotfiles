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
  spotify = config.celo.modules.programs.ui.spotify;
in
{
  config = lib.mkIf cfg.enable (
    util.mkPath path {
      currentlyPlaying = lib.mkIf spotify.enable ''
        osascript -e '
        tell application "System Events"
          set process_list to (name of every process)
        end tell

        if process_list contains "Spotify" then
          tell application "Spotify"
            if player state is playing or player state is paused then
              set track_name to name of current track
              set artist_name to artist of current track
              if player state is playing then
                set now_playing to " " & artist_name & " - " & track_name
              else
                set now_playing to " " & artist_name & " - " & track_name
              end if
              set now_playing_trim to now_playing
            end if
          end tell
        end if'
      '';
    }
  );
}
