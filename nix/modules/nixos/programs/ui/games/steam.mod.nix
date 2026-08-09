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
  xdg = util.xdg config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "dataHome"}/Steam"
        ".steam"
      ];
    };
  };
}
