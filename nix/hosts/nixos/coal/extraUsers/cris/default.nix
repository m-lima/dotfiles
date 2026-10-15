user:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  celo = config.home-manager.users.celo;
  home = "/home/${user}";
  xdg = value: config.home-manager.users.${user}.xdg.${value};
  xdgRel = value: lib.removePrefix "${home}/" (xdg value);
  secret = {
    user.password = "${user}.user.password";
  };
in
{
  age.secrets = {
    ${secret.user.password} = {
      rekeyFile = ./_secrets/user/password.age;
    };
  };

  users.users.${user} = {
    inherit home;
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.${secret.user.password}.path;
  };

  home-manager = util.given.userHome config user {
    home = {
      stateVersion = celo.home.stateVersion;
      username = user;
      homeDirectory = home;
    };

    programs = {
      home-manager.enable = true;
      firefox = {
        enable = true;

        package = pkgs.firefox-esr;
        configPath = "${xdg "configHome"}/mozilla/firefox";

        policies =
          let
            lock = value: {
              Value = value;
              Status = "locked";
            };
          in
          {
            AppAutoUpdate = false;
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            DontCheckDefaultBrowser = true;
            DisablePocket = true;
            TranslateEnabled = false;

            Preferences = {
              "extensions.pocket.enabled" = lock false;
              "browser.newtabpage.pinned" = lock "";
              "browser.topsites.contile.enabled" = lock false;
              "browser.newtabpage.activity-stream.showSponsored" = lock false;
              "browser.newtabpage.activity-stream.system.showSponsored" = lock false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock false;

              "browser.tabs.warnOnClose" = lock true;
            };

            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };

              "@testpilot-containers" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
                installation_mode = "force_installed";
              };
            };

            SearchEngines = {
              Add = [
                {
                  Name = "Startpage";
                  URLTemplate = "https://www.startpage.com/do/dsearch?prfe=baa13e74d1af35e52f6ab557264626250d4a32cc9650578c6de926fc68bca6ba896285c6056e0c2849c0f10b1c9874c7ba3e7e4b77659be952d99414bd3fd306b46742078bcc52a6943d3d5f&q={searchTerms}";
                }
                {
                  Name = "StartpagePost";
                  URLTemplate = "https://www.startpage.com/sp/search";
                  Method = "POST";
                  PostData = "prfe=baa13e74d1af35e52f6ab557264626250d4a32cc9650578c6de926fc68bca6ba896285c6056e0c2849c0f10b1c9874c7ba3e7e4b77659be952d99414bd3fd306b46742078bcc52a6943d3d5f&query={searchTerms}";
                }
              ];
              Default = "StartpagePost";
            };
          };

        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;

            settings = {
              "browser.compactmode.show" = true;
            };
          };
        };
      };
      plasma = {
        enable = true;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
        };

        input = {
          keyboard = {
            layouts = [
              {
                layout = "us";
                variant = "mac";
              }
            ];
            # This is changing the actual CAPS,
            # so in the split it would also become an escape
            # options = [ "caps:escape" ];
          };
        };

        kwin = {
          virtualDesktops = {
            number = 4;
            rows = 2;
          };

          titlebarButtons = {
            left = [
              "more-window-actions"
              "application-menu"
              "on-all-desktops"
              "keep-above-windows"
              "hide-from-screencast"
            ];
          };
        };

        # Show all applications on TaskSwitcher
        configFile = {
          kwinrc = {
            TabBox = {
              DesktopMode = 0;
            };
          };

          kwalletrc = {
            Wallet = {
              "Default Wallet" = "kdewallet";
              "First Use" = false;
              "Use One Wallet" = true;
            };
          };
        };

        session.sessionRestore = {
          restoreOpenApplicationsOnLogin = "startWithEmptySession";
        };

        powerdevil = {
          general.pausePlayersOnSuspend = false;
          AC.autoSuspend.action = "nothing";
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
            "Window Above Other Windows" = "Meta+Shift+Ctrl+F";
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
            "Window to Next Screen" = "Meta+Ctrl+Tab";
            "Window to Previous Screen" = "Meta+Shift+Ctrl+Tab";
            "view_actual_size" = "Meta+)";
            "view_zoom_in" = "Meta++";
            "view_zoom_out" = "Meta+_";
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

        panels = [
          {
            screen = 0;
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
                    "preferred://filemanager"
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

  environment.persistence = util.given.userImpermanence config user {
    files = [
      "${xdgRel "configHome"}/kwinoutputconfig.json"
    ];

    directories = [
      "${xdgRel "dataHome"}/kwalletd"
      "${xdgRel "configHome"}/mozilla/firefox"
      "${xdgRel "cacheHome"}/mozilla/firefox"
      ".mozilla"
      "Downloads"
      "Documents"
      "Music"
      "Pictures"
      "Videos"
    ];
  };
}
