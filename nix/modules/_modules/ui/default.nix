{ lib, ... }:
{
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
