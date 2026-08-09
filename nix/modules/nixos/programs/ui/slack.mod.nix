path:
{
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [ pkgs.slack ];
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "configHome"}/Slack"
      ];
    };
  };
}
