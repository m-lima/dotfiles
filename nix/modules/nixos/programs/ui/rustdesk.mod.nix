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
      home.packages = [ pkgs.rustdesk-flutter ];
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".config/rustdesk"
      ];
    };
  };
}
