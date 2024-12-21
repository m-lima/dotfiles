path:
{
  config,
  util,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
in
{
  config = util.enforceHome path config cfg.enable {
    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".local/share/kwalletd"
      ];
      home.files = [
        ".config/kwalletrc"
      ];
    };
  };
}
