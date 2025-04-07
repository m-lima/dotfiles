{ lib, ... }:
let
  findFiles =
    mark: path: parents:
    let
      innerFindModules = lib.pipe path [
        builtins.readDir
        (lib.mapAttrsToList (
          name: type:
          let
            fullPath = /.${path}/${name};
          in
          if type == "directory" then
            findFiles mark fullPath (parents ++ [ name ])
          else
            lib.optional (lib.hasSuffix ".${mark}.nix" name) {
              file = fullPath;
              path =
                parents
                ++ (lib.optional (name != "default.${mark}.nix") (lib.strings.removeSuffix ".${mark}.nix" name));
            }
        ))
      ];
    in
    lib.flatten innerFindModules;
  loadModules =
    root:
    map ({ file, path }: (import file) path) (
      findFiles "mod" root [
        "celo"
        "modules"
      ]
    );
  loadProfiles =
    root:
    map ({ file, path }: { config, ... }: mkProfile path config (import file)) (
      findFiles "pro" root [
        "celo"
        "profiles"
      ]
    );

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

  mkProfile = path: config: profile: {
    options = mkOptions path { description = "${lib.last path} profile"; };
    config.celo.modules = lib.mkIf (getOptions path config).enable profile;
  };

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
            assertion = config.celo.modules.core.user.home.enable;
            message = "${lib.last path} enabled without home-manager";
          }
        ] ++ assertions;

        home-manager = withHome config home-manager;
      }
    );

  withHome =
    config: settings:
    let
      user = config.celo.modules.core.user;
    in
    lib.mkIf user.home.enable { users.${user.userName} = settings; };

  withImpermanence =
    config:
    {
      global ? { },
      home ? { },
    }:
    let
      impermanence = config.celo.modules.core.impermanence;
      user = config.celo.modules.core.user;
    in
    lib.mkIf impermanence.enable {
      "/persist" = global // {
        users.${user.userName} = lib.mkIf user.enable home;
      };
    };

  mkSecretPath =
    path: name: lib.strings.concatStringsSep "." (builtins.tail (builtins.tail path)) + ".${name}";

  xdg = config: config.home-manager.users.${config.celo.modules.core.user.userName}.xdg;

  rageSecret =
    config: secret:
    if builtins.hasAttr "decrypt" builtins then
      [
        (builtins.decrypt (/. + builtins.toPath config.ragenix.key) secret)
      ]
    else
      builtins.warn "Ragenix is not yet initialized. Skipping ${secret}" [ ];

  linesTrimmed =
    string:
    builtins.filter (s: s != "") (
      builtins.filter builtins.isString (builtins.split "[[:space:]]*\n[[:space:]]*" string)
    );

in
{
  inherit
    loadModules
    loadProfiles
    mkOptions
    mkOptionsEnable
    getOptions
    mkColorOption
    withHome
    enforceHome
    withImpermanence
    mkSecretPath
    xdg
    rageSecret
    linesTrimmed
    ;
}
