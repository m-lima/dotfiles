path:
{
  config,
  util,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.plasma = {
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
  };
}
