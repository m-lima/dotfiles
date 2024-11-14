path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOption path config;
in {
  options = util.mkModule path {
    userName = lib.mkOption {
      description = "User name";
      example = "celo";
      type = lib.types.nonEmptyStr;
    };

    homeDirectory = lib.mkOption {
      description = "Home directory path";
      example = "/home/celo";
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${cfg.userName} = {
          isNormalUser = true;
          home = cfg.homeDirectory;
          hashedPasswordFile = "/persist/secrets/${cfg.userName}.passwordFile";
          extraGroups = [ "wheel" ];
        };
      };
    };
  };
}
