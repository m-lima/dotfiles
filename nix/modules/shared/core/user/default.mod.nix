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
    userName = lib.mkOption {
      description = "User name";
      default = "celo";
      example = "celo";
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
        };
      };
    };
  };
}

