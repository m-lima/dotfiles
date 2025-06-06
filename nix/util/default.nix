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
            fullPath = /${path}/${name};
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
            assertion = config.celo.modules.core.home.enable;
            message = "${lib.last path} enabled without home-manager";
          }
        ] ++ assertions;

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

  mkSecretPath =
    path: name: lib.strings.concatStringsSep "." (builtins.tail (builtins.tail path)) + ".${name}";

  xdg = config: config.home-manager.users.${config.celo.modules.core.user.userName}.xdg;

  rageSecret =
    config: secret:
    if builtins.hasAttr "decrypt" builtins then
      let
        result = builtins.decrypt /${builtins.toPath config.ragenix.key} secret;
      in
      if builtins.hasAttr "ok" result then
        [
          result.ok
        ]
      else
        builtins.warn "${result.err}. Skipping ${secret}" [ ]
    else
      builtins.warn "Ragenix is not yet initialized. Skipping ${secret}" [ ];

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
    loadModules
    loadProfiles
    mkPath
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
    extractCompdef
    ;
}
