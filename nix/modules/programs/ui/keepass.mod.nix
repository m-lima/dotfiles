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
    home-manager = {
      home.packages = with pkgs; [ keepassxc ];
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".cache/keepassxc"
        ".config/keepassxc"
      ];
    };
  };
}
