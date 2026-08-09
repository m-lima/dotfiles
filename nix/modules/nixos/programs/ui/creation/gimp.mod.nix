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
        packages = [ pkgs.gimp ];
      };
    };

    celo.modules.programs.ui.creation.persist = true;
    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "cacheHome"}/gimp"
        "${xdg.rel "configHome"}/GIMP"
      ];
    };
  };
}
