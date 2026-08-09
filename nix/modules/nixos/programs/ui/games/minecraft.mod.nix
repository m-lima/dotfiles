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
      home.packages = [ pkgs.prismlauncher ];
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [
        "${xdg.rel "dataHome"}/PrismLauncher"
      ];
    };
  };
}
