path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOpion path config;
in {
  options = util.mkModuleEnableOption path {
    userName = lib.mkOption {
      description = "User name";
      example = "celo";
      type = lib.types.nonEmptyStr;
    };

    homeDirectory = {
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
