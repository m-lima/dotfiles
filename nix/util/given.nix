{ lib }:
let
  impermanence =
    config:
    {
      global ? { },
      home ? { },
    }:
    let
      core = config.celo.modules.core;
    in
    lib.mkIf (builtins.hasAttr "impermanence" core && core.impermanence.enable) {
      ${config.celo.modules.core.disko.mounts.persist.mountpoint} = global // {
        users.${core.user.userName} = lib.mkIf core.user.enable home;
      };
    };

  userImpermanence =
    config: user: home:
    let
      core = config.celo.modules.core;
    in
    lib.mkIf (builtins.hasAttr "impermanence" core && core.impermanence.enable) {
      ${config.celo.modules.core.disko.mounts.persist.mountpoint} = {
        users.${user} = home;
      };
    };

  enforcedHome =
    path: config: enable:
    enforcedUserHome (lib.last path) config config.celo.modules.core.user.userName enable;

  enforcedUserHome =
    name: config: user: enable:
    {
      assertions ? [ ],
      home-manager ? { },
      ...
    }@settings:
    lib.mkIf enable (
      (removeAttrs settings [
        "assertions"
        "home-manager"
      ])
      // {
        assertions = [
          {
            assertion = config.celo.modules.core.home.enable;
            message = "${name} enabled without home-manager";
          }
        ]
        ++ assertions;

        home-manager = userHome config user home-manager;
      }
    );

  home =
    config: settings:
    lib.mkIf config.celo.modules.core.home.enable {
      users.${config.celo.modules.core.user.userName} = settings;
    };

  userHome =
    config: user: settings:
    lib.mkIf config.celo.modules.core.home.enable { users.${user} = settings; };
in
{
  inherit
    impermanence
    userImpermanence
    enforcedHome
    enforcedUserHome
    home
    userHome
    ;
}
