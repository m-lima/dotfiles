path:
{
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      home.packages = [
        (pkgs.callPackage ./rustdesk.pkg.nix { })
      ];
    };
  };
}
