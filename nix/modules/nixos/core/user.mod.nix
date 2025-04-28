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
      default = "/home/${cfg.userName}";
      example = "/home/celo";
      type = lib.types.nonEmptyStr;
    };

    motd = options.users.motd;
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${cfg.userName} = {
          extraGroups = [ "wheel" ];
        };
      };
      motd = cfg.motd;
    };
  };
}
