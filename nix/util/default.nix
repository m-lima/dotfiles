{
  lib,
  ...
}:
let
  findModules =
    path:
    parents:
    let
      innerFindModules =
        lib.pipe path [
          builtins.readDir
          (
            lib.mapAttrsToList (
              name:
              type:
              let
                fullPath = /.${path}/${name};
              in
                if type == "directory"
                then findModules fullPath (parents ++ [name])
                else lib.optional (lib.hasSuffix ".mod.nix" name)
                  {
                    file = fullPath;
                    path = parents ++ (lib.optional (name != "default.mod.nix") (lib.strings.removeSuffix ".mod.nix" name));
                  }
            )
          )
        ];
    in
      lib.flatten innerFindModules;
  load = root: map ({file, path}: (import file) path) (findModules root ["celo"]);

  mkModule =
    path:
    options@{ description ? (lib.last path), ... }:
    lib.setAttrByPath path (
        { enable = lib.mkEnableOption description; }
        // (removeAttrs options [ "description" ])
      );
  mkModuleEnable = path: mkModule path {};

  getModuleOption = path: config: lib.getAttrFromPath path config;

  mkColorOption = name: default: lib.mkOption {
    type = lib.types.nonEmptyStr;
    description = "Color in hex for `${name}`";
    default = default;
    example = "ffa500";
  };
in {
  inherit
    load
    mkModule
    mkModuleEnable
    getModuleOption
    mkColorOption
  ;
}
