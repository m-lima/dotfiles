{ lib, ... }@input:
let
  mkPath = path: base: lib.setAttrByPath path base;

  mkOptions =
    path:
    options@{
      description ? (lib.last path),
      ...
    }:
    lib.setAttrByPath path (
      { enable = lib.mkEnableOption description; } // (removeAttrs options [ "description" ])
    );
  mkOptionsEnable = path: mkOptions path { };

  getOptions = path: config: lib.getAttrFromPath path config;

  mkColorOption =
    name: default:
    lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Color in hex for `${name}`";
      default = default;
      example = "ffa500";
    };

  enforceHome =
    path: config: enable:
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
            message = "${lib.last path} enabled without home-manager";
          }
        ]
        ++ assertions;

        home-manager = withHome config home-manager;
      }
    );

  withHome =
    config: settings:
    let
      core = config.celo.modules.core;
    in
    lib.mkIf core.home.enable { users.${core.user.userName} = settings; };

  withImpermanence =
    config:
    {
      global ? { },
      home ? { },
    }:
    let
      core = config.celo.modules.core;
    in
    lib.mkIf (builtins.hasAttr "impermanence" core && core.impermanence.enable) {
      "/persist" = global // {
        users.${core.user.userName} = lib.mkIf core.user.enable home;
      };
    };

  xdg = config: config.home-manager.users.${config.celo.modules.core.user.userName}.xdg;

  extractCompdef =
    string:
    lib.concatStringsSep "\n" (
      builtins.filter (s: builtins.isString s && lib.hasPrefix "compdef " s) (
        builtins.split "[[:space:]]*\n[[:space:]]*" string
      )
    );

in
{
  inherit
    mkPath
    mkOptions
    mkOptionsEnable
    getOptions
    mkColorOption
    withHome
    enforceHome
    withImpermanence
    xdg
    extractCompdef
    ;
  load = (import ./load.nix) { inherit lib mkOptions getOptions; };
  secret = (import ./secret.nix) { inherit lib; };
}
