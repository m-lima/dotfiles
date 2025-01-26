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
    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          # TDOO: Don't assume impermanence
          # TODO: Use ragenix
          hashedPasswordFile = util.warnMissingFile "/persist/secrets/${cfg.userName}/passwordFile";
          extraGroups = [ "wheel" ];
        };
      };
      motd = cfg.motd;
    };
  };
}
