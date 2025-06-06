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
        (builtins.getFlake "${url}?ref=master&rev=a9f510d5bb7686859ab5bdbafa1027a35d414ee4")
        .outputs.packages.${pkgs.system}.default
      ) (util.rageSecret config ./_secrets/${host}/url.rage);
    };
  };
}
