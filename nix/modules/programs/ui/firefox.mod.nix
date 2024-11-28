path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home = {
        packages = with pkgs; [
          firefox
        ];
      };

      programs = {
        firefox = {
          enable = true;

          policies =
          let
            lock-false = {
              Value = false;
              Status = "locked";
            };
            lock-true = {
              Value = true;
              Status = "locked";
            };
            lock-empty = {
              Value = "";
              Status = "locked";
            };
          in
          {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            DontCheckDefaultBrowser = true;
            DisablePocket = true;

            Preferences = {
              "extensions.pocket.enabled" = lock-false;
              "browser.newtabpage.pinned" = lock-empty;
              "browser.topsites.contile.enabled" = lock-false;
              "browser.newtabpage.activity-stream.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            };

            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };
              "{20fc2e06-e3e4-4b2b-812b-ab431220cada}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/startpage-private-search/latest.xpi";
                installation_mode = "force_installed";
              };
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

              search = {
                default = "Startpage";

                engines = {
                  "Startpage" = {
                    urls = [
                      {
                        template = "https://www.startpage.com/do/dsearch";
                        params = [
                            {
                              name = "q";
                              value = "{searchTerms}";
                            }
                        ];
                      }
                    ];
                  };
                };
              };
            };
          };
        };
      };

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$browser" = "firefox";
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".mozilla"
        ".cache/mozilla"
      ];
    };
  };
}
