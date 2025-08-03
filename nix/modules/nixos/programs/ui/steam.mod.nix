path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        ".local/share/Steam"
      ];
    };
  };
}
