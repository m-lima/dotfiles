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
  options = util.mkOptions path {
    multiAccount = lib.mkEnableOption "multi-account containers";
  };

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs = {
        firefox = {
          enable = true;
          package = pkgs.firefox-esr;

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

              ExtensionSettings =
                {
                  "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                  };
                  # "{20fc2e06-e3e4-4b2b-812b-ab431220cada}" = {
                  #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/startpage-private-search/latest.xpi";
                  #   installation_mode = "force_installed";
                  # };
                }
                // (lib.optionalAttrs cfg.multiAccount {
                  "@testpilot-containers" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
                    installation_mode = "force_installed";
                  };
                });

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
      };

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$browser" = "firefox-esr";
        };
      };

    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".mozilla"
        ".cache/mozilla"
        "Downloads"
      ];
    };
  };
}
