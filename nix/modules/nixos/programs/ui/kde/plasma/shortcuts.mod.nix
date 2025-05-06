path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
  alacrittyCfg = config.celo.modules.programs.ui.alacritty;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.plasma = {
        hotkeys.commands = lib.mkIf alacrittyCfg.enable {
          "launch-terminal" = {
            name = "Lauch terminal";
            key = "Meta+T";
            command = "alacritty";
          };
        };

        spectacle = {
          shortcuts = {
            launch = "Print";
            captureEntireDesktop = "Meta+Ctrl+1";
            captureWindowUnderCursor = "Meta+Ctrl+2";
            captureRectangularRegion = "Meta+Ctrl+3";
            recordScreen = "Meta+Ctrl+4";
            recordWindow = "Meta+Ctrl+5";
            recordRegion = "Meta+Ctrl+6";
          };
        };

        shortcuts = {
          kwin = {
            "Window Fullscreen" = "Meta+Shift+F";
            "Window Close" = [
              "Meta+Shift+Q"
              "Alt+F4"
            ];
            "Walk Through Windows" = "Meta+Tab";
            "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
            "Walk Through Windows of Current Application" = "Meta+`";
            "Walk Through Windows of Current Application (Reverse)" = "Meta+~";
            "Switch to Desktop 1" = "Meta+!";
            "Switch to Desktop 2" = "Meta+@";
            "Switch to Desktop 3" = "Meta+#";
            "Switch to Desktop 4" = "Meta+$";
            "Window One Desktop to the Left" = "Meta+Shift+Left";
            "Window One Desktop Down" = "Meta+Shift+Down";
            "Window One Desktop Up" = "Meta+Shift+Up";
            "Window One Desktop to the Right" = "Meta+Shift+Right";
            "Window to Next Screen" = "";
            "Window to Previous Screen" = "";
          };
          plasmashell = {
            "show-on-mouse-pos" = "Meta+Shift+V";
            "next activity" = "";
          };
          "services/org.kde.krunner.desktop" = {
            _launch = [
              "Search"
              "Meta+Space"
            ];
          };
        };

        configFile = {
          kdeglobals = {
            Shortcuts = {
              Copy = "Ctrl+Ins; Ctrl+C; Meta+C";
              Cut = "Ctrl+X; Meta+X";
              Find = "Ctrl+F; Meta+F";
              Paste = "Shift+Ins; Ctrl+V; Meta+V";
              Redo = "Ctrl+Shift+Z; Meta+Shift+Z";
              SelectAll = "Ctrl+A; Meta+A";
              Undo = "Ctrl+Z; Meta+Z";
            };
          };
        };
      };
    };
  };
}
