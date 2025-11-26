path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.less = {
        enable = true;
        keys = ''
          #command
          l right-scroll
          h left-scroll
          j forw-line-force 4
          k back-line-force 4
          #env
          LESS = -F -i -M -R -S -w -z-4
        '';
      };
    };
  };
}
