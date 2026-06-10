path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    primaryUser = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "User to which apply the darwin nix changes";
      default = config.celo.modules.core.user.userName;
    };
  };

  config = lib.mkIf cfg.enable {
    system = {
      primaryUser = cfg.primaryUser;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
      defaults = {
        ActivityMonitor.IconType = 5;
        controlcenter = {
          Bluetooth = true;
        };
        dock = {
          largesize = 56;
          magnification = true;
          orientation = "left";
          show-process-indicators = false;
          show-recents = false;
          static-only = true;
          tilesize = 32;
        };
        iCal."first day of week" = "Sunday";
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleMetricUnits = 1;
        };
        CustomUserPreferences = {
          "com.apple.Spotlight" = {
            "MenuItemHidden" = 1;
          };
          NSGlobalDomain = {
            AppleICUNumberSymbols = {
              "0" = ".";
              "1" = "";
              "8" = "$";
              "10" = ".";
              "17" = ",";
            };
          };
        };
      };
    };
  };
}
