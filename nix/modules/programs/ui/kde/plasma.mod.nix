path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.plasma = {
        enable = true;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
        };

        hotkeys.commands."launch-terminal" = {
          name = "Lauch terminal";
          key = "Meta+T";
          command = "alacritty";
        };

        kwin = {
          virtualDesktops = {
            number = 4;
            rows = 2;
          };
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      home.files = [ ".config/kwinoutputconfig.json" ];
    };
  };
}
