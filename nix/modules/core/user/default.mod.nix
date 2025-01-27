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
  secret = "${cfg.userName}-${host}";
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
    # TODO: Bring coal to the party
    age.secrets = lib.mkIf (host != "coal") {
      ${util.mkSecretPath path secret} = {
        rekeyFile = ./secrets/${secret}.age;
      };
    };

    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          hashedPasswordFile =
            if host != "coal" then
              config.age.secrets.${util.mkSecretPath path secret}.path
            else
              # TODO: Remove when not needed
              util.warnMissingFile "/persist/secrets/${cfg.userName}/passwordFile";
          extraGroups = [ "wheel" ];
        };
      };
      motd = cfg.motd;
    };
  };
}
