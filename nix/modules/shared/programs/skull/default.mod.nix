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
        (builtins.getFlake "${url}?ref=master&rev=d3e713dcb3888966fbf86b24ef736b034c859442")
        .outputs.packages.${pkgs.system}.default
      ) (util.rageSecret config ./_secrets/${host}/url.rage);
    };
  };
}
