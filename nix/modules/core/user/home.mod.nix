path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOpion path config;
  user = config.celo.core.user;
in {
  options = util.mkModuleEnableOption path {};

  assertions = [
    {
      assertion = user.enable;
      message = "Home manager enabled with user disabled";
    }
  ];

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users = {
        "${user.userName}" = {
          programs.home-manager.enable = true;
          home = {
            stateVersion = "24.05";
            username = "${user.userName}";
            homeDirectory = "${user.homeDirectory}";
          };
        };
      };
  };
}
