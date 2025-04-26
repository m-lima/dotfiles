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
  kdeCfg = config.celo.modules.programs.ui.kde;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = !kdeCfg.enable;
        message = "Conflicting secret manager with KWallet from KDE";
      }
    ];

    services.gnome-keyring.enable = true;
  };
}
