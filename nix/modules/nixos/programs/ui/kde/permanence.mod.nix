path:
{
  config,
  util,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
  xdg = util.xdg config;
in
{
  config = util.given.enforcedHome path config cfg.enable {
    environment.persistence = util.given.impermanence config {
      home.files = [
        "${xdg.rel "configHome"}/kwinoutputconfig.json"
      ];

      home.directories = [
        "Documents"
        "Music"
        "Pictures"
        "Videos"
      ]
      ++ [
        (if cfg.useGnomeKeyring then "${xdg.rel "dataHome"}/keyrings" else "${xdg.rel "dataHome"}/kwalletd")
      ];
    };
  };
}
