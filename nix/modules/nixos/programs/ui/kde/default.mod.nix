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
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      desktopManager.plasma6 = {
        enable = true;
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
