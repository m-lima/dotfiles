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
        (builtins.getFlake "${url}?ref=master&rev=cb3ab9eb59d18baa564850e4087feb7b2c4d147d")
        .outputs.packages.${pkgs.system}.default
      ) (util.rageSecret config ../../hosts/${host}/secrets/programs/skull/url.age);
    };

    environment.persistence = util.withImpermanence config {
      home.directories = [ ".local/share/Skull" ];
    };
  };
}
