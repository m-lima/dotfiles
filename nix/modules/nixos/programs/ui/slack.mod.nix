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
  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      home.packages = [ pkgs.slack ];
    };

    environment.persistence = util.given.impermanence config {
      home.directories = [
        "${xdg.rel "configHome"}/Slack"
      ];
    };
  };
}
