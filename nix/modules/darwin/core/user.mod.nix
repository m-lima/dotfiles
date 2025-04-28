path:
{
  lib,
  config,
  util,
  options,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkRawOptions path {
    homeDirectory = lib.mkOption {
      description = "Home directory path";
      default = "/Users/${cfg.userName}";
      example = "/Users/celo";
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${cfg.userName} = {
          extraGroups = [ "staff" ];
        };
      };
    };
  };
}
