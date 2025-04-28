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
  options = util.mkOptions path {
    usersDirectory = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.nonEmptyStr;
    };

    userName = lib.mkOption {
      description = "User name";
      default = "celo";
      example = "celo";
      type = lib.types.nonEmptyStr;
    };

    homeDirectory = lib.mkOption {
      description = "Home directory path";
      default = "/${cfg.usersDirectory}/${cfg.userName}";
      example = "/${cfg.usersDirectory}/celo";
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${cfg.userName} = {
          home = cfg.homeDirectory;
        };
      };
    };
  };
}
