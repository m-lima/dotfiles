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

        kwin = {
          virtualDesktops = {
            number = 4;
            rows = 2;
          };
        };

        # Show all applications on TaskSwitcher
        configFile."kwinrc" = {
          TabBox = {
            DesktopMode = 0;
          };
        };

        session.sessionRestore = {
          restoreOpenApplicationsOnLogin = "startWithEmptySession";
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      home.files = [ ".config/kwinoutputconfig.json" ];
    };
  };
}
