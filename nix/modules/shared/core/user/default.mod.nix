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
  host = config.celo.host.id;
in
{
  options = util.mkOptions path {
    usersDirectory = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.nonEmptyStr;
    };

    extraGroups = lib.mkOption {
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
    age.secrets = {
      ${util.mkSecretPath path host} = {
        rekeyFile = ./_secrets/${host}/password.age;
      };
    };

    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          hashedPasswordFile = config.age.secrets.${util.mkSecretPath path host}.path;
          extraGroups = [ cfg.extraGroups ];
        };
      };
    };
  };
}
