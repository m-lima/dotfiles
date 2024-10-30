{
  lib,
  config,
  ...
}:
let
  mkUiIf = check: lib.mkIf (config.modules.ui.enable && check);
in {
  imports = [
    ./hardware
    ./programs
    ./services
  ];

  options = {
    modules.ui = {
      enable = lib.mkEnableOption "UI tools";
    };
  };
}
