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
  user = config.celo.modules.core.user;
  secret = "${user.userName}-${config.celo.host.id}";
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
    age.secrets = lib.mkIf (config.celo.host.id == "utm") {
      ${util.mkSecretPath path secret} = {
        rekeyFile = ./secrets/${secret}.age;
      };
    };

    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          # TDOO: Don't assume impermanence
          # TODO: Use ragenix
          hashedPasswordFile =
            if config.celo.host.id == "utm" then
              config.age.secrets.${util.mkSecretPath path secret}.path
            else
              util.warnMissingFile "/persist/secrets/${cfg.userName}/passwordFile";
          extraGroups = [ "wheel" ];
        };
      };
      motd = cfg.motd;
    };
  };
}
