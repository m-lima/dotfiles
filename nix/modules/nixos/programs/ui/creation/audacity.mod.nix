path:
{
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
in
{
  config = util.enforceHome path config cfg.enable {

    celo.modules.programs.ui.creation.persist = true;

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "configHome"}/audacity"
        "${xdg.rel "dataHome"}/audacity"
      ];
    };
  };
}
