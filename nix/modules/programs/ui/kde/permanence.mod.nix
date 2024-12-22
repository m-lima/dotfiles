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
      home.files = [
        ".config/kwalletrc"
        ".config/kwinoutputconfig.json"
      ];
      home.directories = [
        ".local/share/kwalletd"
        "Documents"
        "Music"
        "Pictures"
        "Videos"
      ];
    };
  };
}
