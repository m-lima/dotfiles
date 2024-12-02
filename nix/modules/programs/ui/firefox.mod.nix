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
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome path config) ];

    home-manager = util.withHome config {
      programs = {
        firefox = {
          enable = true;

          policies =
            let
              lock = value: {
                Value = value;
                Status = "locked";
              };
            in
            {
              DisableTelemetry = true;
              DisableFirefoxStudies = true;
              DontCheckDefaultBrowser = true;
              DisablePocket = true;

              Preferences = {
                "extensions.pocket.enabled" = lock false;
                "browser.newtabpage.pinned" = lock "";
                "browser.topsites.contile.enabled" = lock false;
                "browser.newtabpage.activity-stream.showSponsored" = lock false;
                "browser.newtabpage.activity-stream.system.showSponsored" = lock false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock false;
              };

              ExtensionSettings = {
                "uBlock0@raymondhill.net" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
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
                            name = "prfe";
                            value = "baa13e74d1af35e52f6ab557264626250d4a32cc9650578c6de926fc68bca6ba896285c6056e0c2849c0f10b1c9874c7ba3e7e4b77659be952d99414bd3fd306b46742078bcc52a6943d3d5f";
                          }
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
  };
}
