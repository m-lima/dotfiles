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
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6 = {
      enable = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      kate
      khelpcenter
      konsole
      plasma-browser-integration
    ];

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".local/share/kwalletd"
      ];
      home.files = [
        ".config/kwalletrc"
      ];
    };
  };
}
