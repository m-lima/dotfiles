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
  options = util.mkModuleEnable path;

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

