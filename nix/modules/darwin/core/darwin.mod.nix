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
          showAppExposeGestureEnabled = true;
          static-only = true;
          tilesize = 32;
        };
        iCal."first day of week" = "Sunday";
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleMetricUnits = 1;
        };
        WindowManager = {
          EnableStandardClickToShowDesktop = false;
          StageManagerHideWidgets = true;
          StandardHideWidgets = true;
        };
        CustomUserPreferences = {
          "com.apple.Spotlight" = {
            # Hide from the menu bar
            MenuItemHidden = 1;
            # Disable unwanted sources
            DisabledUTTypes = [
              "com.adobe.pdf"
              "com.apple.applescript.alias-object"
              "com.apple.applescript.data-object"
              "com.apple.applescript.text-object"
              "com.apple.applescript.url-object"
              "com.apple.coreanimation-bundle"
              "com.apple.coreanimation-xml"
              "com.apple.dashcode.css"
              "com.apple.dashcode.javascript"
              "com.apple.dashcode.json"
              "com.apple.dashcode.manifest"
              "com.apple.dashcode.xml"
              "com.apple.dt.bundle.unit-test.objective-c"
              "com.apple.dt.document.scheme"
              "com.apple.dt.document.snapshot"
              "com.apple.dt.document.workspace"
              "com.apple.dt.dvt.plug-in"
              "com.apple.dt.ide.plug-in"
              "com.apple.dt.playground"
              "com.apple.instruments.tracetemplate"
              "com.apple.interfacebuilder.document"
              "com.apple.interfacebuilder.document.cocoa"
              "com.apple.iphone.developerprofile"
              "com.apple.iphone.mobileprovision"
              "com.apple.iwork.keynote.key"
              "com.apple.iwork.numbers.numbers"
              "com.apple.iwork.numbers.sffnumbers"
              "com.apple.iwork.numbers.template"
              "com.apple.keynote.key"
              "com.apple.localized-pdf-bundle"
              "com.apple.mach-o-binary"
              "com.apple.mach-o-executable"
              "com.apple.mach-o-object"
              "com.apple.property-list"
              "com.apple.protected-mpeg-4-audio"
              "com.apple.quartzdebug.introspectiontrace"
              "com.apple.quicktime-movie"
              "com.apple.rez-source"
              "com.apple.scripting-definition"
              "com.apple.symbol-export"
              "com.apple.x11-mach-o-executable"
              "com.apple.xcode.archive"
              "com.apple.xcode.configsettings"
              "com.apple.xcode.docset"
              "com.apple.xcode.dsym"
              "com.apple.xcode.model"
              "com.apple.xcode.mom"
              "com.apple.xcode.plugin"
              "com.apple.xcode.plugindata"
              "com.apple.xcode.project"
              "com.apple.xcode.projectdata"
              "com.apple.xcode.strings-text"
              "com.apple.xcode.usersettings"
              "com.microsoft.excel.sheet.binary.macroenabled"
              "com.microsoft.excel.xls"
              "com.microsoft.powerpoint.ppt"
              "com.microsoft.windows-dynamic-link-library"
              "com.microsoft.windows-executable"
              "com.sun.java-archive"
              "com.sun.java-class"
              "com.sun.web-application-archive"
              "dyn.ah62d4rv4ge80u5pbsa"
              "dyn.ah62d4rv4ge81a7dk"
              "org.openxmlformats.spreadsheetml.sheet"
              "org.openxmlformats.spreadsheetml.sheet.macroenabled"
              "public.3gpp"
              "public.3gpp2"
              "public.audio"
              "public.html"
              "public.image"
              "public.movie"
              "public.mpeg"
              "public.mpeg-4"
              "public.mpeg-4-audio"
              "public.mpeg-video"
              "public.object-code"
              "public.presentation"
              "public.shell-script"
              "public.source-code"
              "public.spreadsheet"
              "public.unix-executable"
              "public.xhtml"
              "public.xml"
            ];
            # Disable unwanted sources
            EnabledPreferenceRules = [
              "Custom.relatedContents"
              "Domain.SOURCE"
              "System.documents"
              "Domain.IMAGES"
              "Domain.MOVIES"
              "Domain.MUSIC"
              "Domain.MENU_OTHER"
              "Domain.PDF"
              "Domain.PRESENTATIONS"
              "Domain.SPREADSHEETS"
              "System.files"
              "System.folders"
              "com.apple.tips"
            ];
          };
          # Help Apple Improve Search
          "com.apple.assistant.support" = {
            "Search Queries Data Sharing Status" = 2;
          };
          NSGlobalDomain = {
            # Number format
            AppleICUNumberSymbols = {
              # Decimal separator
              "0" = ".";
              # Thousand separator
              "1" = "";
              # Currency symbol
              "8" = "$";
              # Money ecimal separator
              "10" = ".";
              # Money thousand separator
              "17" = ",";
            };
          };
        };
      };
    };
  };
}
