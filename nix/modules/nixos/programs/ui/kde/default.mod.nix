# TODO: Persist the power options
# TODO: The restart button is not working
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
in
{
  options = util.mkOptions path {
    insomnia = lib.mkEnableOption "insomnia mode";
    useGnomeKeyring = lib.mkEnableOption "gnome-keyring instead of kwallet";
    autoLogin = lib.mkEnableOption "autoLogin";
  };

  imports = [
    {
      config = util.enforceHome path config cfg.useGnomeKeyring {
        services.gnome.gnome-keyring.enable = true;

        security.pam.services.sddm = {
          enableGnomeKeyring = true;
          kwallet.enable = lib.mkForce false;
        };

        home-manager = {
          programs.plasma.configFile.kwalletrc.Wallet.Enable = false;
          xdg.dataFile."keyrings/default".text = "login";
        };

        environment = {
          plasma6.excludePackages = [ pkgs.kdePackages.kwallet ];
        };
      };
    }
  ];

  config = util.enforceHome path config cfg.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = lib.mkIf cfg.autoLogin {
          enable = true;
          user = config.celo.modules.core.user.userName;
        };
      };

      desktopManager.plasma6 = {
        enable = true;
      };
    };

    home-manager = {
      xdg.configFile = lib.mkIf cfg.autoLogin {
        "autostart/autolock.desktop".source =
          let
            autoLockScript = pkgs.writeShellApplication {
              name = "autolock";
              runtimeInputs = [
                pkgs.systemd
                pkgs.glib
              ];
              text = ''
                if [ -z "$XDG_SESSION_ID" ]; then
                  exit 0
                fi

                SERVICE="$(loginctl show-session "$XDG_SESSION_ID" -p Service --value)"

                if [ "$SERVICE" != "sddm-autologin" ]; then
                  exit 0
                fi

                gdbus wait --session --timeout=10 org.freedesktop.ScreenSaver || true

                loginctl lock-session
              '';
            };
            desktopItem = pkgs.makeDesktopItem {
              name = "autolock";
              desktopName = "Lock Screen on Auto-Login";
              type = "Application";
              exec = lib.getExe autoLockScript;
              terminal = false;
              noDisplay = true;
            };
          in
          "${desktopItem}/share/applications/${desktopItem.name}";
      };
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      kate
      khelpcenter
      konsole
      plasma-browser-integration
    ];
  };
}
