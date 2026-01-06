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
  };

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
  };
}
