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
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home = {
        packages = [ pkgs.audacity ];
      };
    };

    celo.modules.programs.ui.creation.persist = true;
    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "configHome"}/audacity"
        "${xdg.rel "dataHome"}/audacity"
      ];
    };
  };
}
