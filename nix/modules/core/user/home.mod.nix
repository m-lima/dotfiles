path:
{
  lib,
  config,
  util,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  user = config.celo.modules.core.user;
in
{
  options = util.mkOptions path { description = "home manager"; };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = user.enable;
        message = "Home manager enabled with user disabled";
      }
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

      users = {
        ${user.userName} = {
          programs.home-manager.enable = true;
          home = {
            stateVersion = "24.05";
            username = "${user.userName}";
            homeDirectory = "${user.homeDirectory}";
          };
        };
      };
    };
  };
}
