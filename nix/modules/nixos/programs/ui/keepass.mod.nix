path:
{
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [ pkgs.keepassxc ];
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".cache/keepassxc"
        ".config/keepassxc"
      ];
    };
  };
}
