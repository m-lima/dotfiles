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
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
    ];

    home-manager = util.withHome config {
      home.file = {
        ".config/git/config" = with builtins; {
          text = ''''
            + readFile ../../../git/config/gitconfig
            # Colors are off
            + readFile ../../../git/config/delta;
        };
        ".config/git/ignore" = {
          source = ../../../git/config/ignore;
        };
      };
    };
  };
}
