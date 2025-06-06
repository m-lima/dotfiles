path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  config = util.enforceHome path config cfg.enable {
    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".config/Slack"
      ];
    };
  };
}
