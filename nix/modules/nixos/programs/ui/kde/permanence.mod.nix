path:
{
  lib,
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
        ".config/kwinoutputconfig.json"
      ]
      ++ (lib.optional (!cfg.useGnomeKeyring) ".config/kwalletrc");

      home.directories = [
        "Documents"
        "Music"
        "Pictures"
        "Videos"
      ]
      ++ [
        (if cfg.useGnomeKeyring then ".local/share/keyrings" else ".local/share/kwalletd")
      ];
    };
  };
}
