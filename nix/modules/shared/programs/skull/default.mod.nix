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
  host = config.celo.host.id;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = map (
        url:
        (builtins.getFlake "${url}?ref=master&rev=04eefab73cc82bcb60d922225f1d46f959222e29")
        .outputs.packages.${pkgs.system}.default
      ) (util.rageSecret config ./_secrets/${host}/url.rage);
    };
  };
}
