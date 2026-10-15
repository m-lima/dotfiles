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

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      home.packages = [ pkgs.prismlauncher ];
    };

    environment.persistence = util.given.impermanence config {
      home.directories = [
        "${xdg.rel "dataHome"}/PrismLauncher"
      ];
    };
  };
}
