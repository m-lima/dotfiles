{
  pkgs,
  lib,
  config,
  sysconfig,
  util,
  ...
}:
let
  cfg = config.home.ui.programs.firefox;
in
{
  options = {
    home.ui.programs.firefox = {
      enable = util.mkDisableOption "firefox";
    };
  };

  config = util.mkIfUi sysconfig cfg.enable {
    home.packages = with pkgs; lib.mkAfter [ firefox ];

    programs = {
      firefox = {
        enable = true;
      };
    };
  };
}
