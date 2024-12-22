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

        panels = [
          {
            floating = true;
            widgets = [
              {
                kickoff = {
                  icon = "nix-snowflake-white";
                };
              }
              "org.kde.plasma.pager"
              {
                iconTasks = {
                  launchers = [
                    "preferred://browser"
                    "applications:Alacritty.desktop"
                    "applications:spotify.desktop"
                    "preferred://filemanager"
                    "applications:systemsettings.desktop"
                  ];
                };
              }
              "org.kde.plasma.marginsseparator"
              {
                systemTray = {
                  items = {
                    hidden = [
                      "Nextcloud"
                      "org.kde.kscreen"
                      "org.kde.plasma.battery"
                      "org.kde.plasma.bluetooth"
                      "org.kde.plasma.brightness"
                      "org.kde.plasma.cameraindicator"
                      "org.kde.plasma.clipboard"
                      "org.kde.plasma.devicenotifier"
                      "org.kde.plasma.keyboardindicator"
                      "org.kde.plasma.keyboardlayout"
                      "org.kde.plasma.manage-inputmethod"
                      "org.kde.plasma.mediacontroller"
                      "org.kde.plasma.notifications"
                      "org.kde.plasma.volume"
                    ];
                  };
                };
              }
              "org.kde.plasma.digitalclock"
            ];
          }
        ];
      };
    };

    environment.persistence = util.withImpermanence config {
      home.files = [ ".config/kwinoutputconfig.json" ];
    };
  };
}
