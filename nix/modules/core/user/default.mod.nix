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
  secret = config.celo.host.id;
in
{
  options = util.mkOptions path {
    userName = lib.mkOption {
      description = "User name";
      default = "celo";
      example = "celo";
      type = lib.types.nonEmptyStr;
    };

    homeDirectory = lib.mkOption {
      description = "Home directory path";
      default = "/home/${cfg.userName}";
      example = "/home/celo";
      type = lib.types.nonEmptyStr;
    };

    motd = options.users.motd;
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      ${util.mkSecretPath path secret} = {
        rekeyFile = ./secrets/${secret}.age;
      };
    };

    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          hashedPasswordFile = config.age.secrets.${util.mkSecretPath path secret}.path;
          extraGroups = [ "wheel" ];
        };
      };
      motd = cfg.motd;
    };
  };
}
