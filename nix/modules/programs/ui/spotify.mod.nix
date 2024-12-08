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
    environment = {
      systemPackages = with pkgs; [
        spotify
        playerctl
      ];

      persistence = util.withImpermanence config {
        home.directories = [
          ".config/spotify"
          ".cache/spotify"
        ];
      };
    };
  };
}
