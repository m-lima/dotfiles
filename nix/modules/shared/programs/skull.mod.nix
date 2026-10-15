path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  skull = inputs.skull.packages.${pkgs.stdenv.hostPlatform.system}.cli;
in
{
  options = util.mkOptionsEnable path;

  config = util.given.enforcedHome path config cfg.enable {
    home-manager.home.packages = [ skull ];
  };
}
