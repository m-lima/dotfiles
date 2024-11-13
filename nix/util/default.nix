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
  load = root: findModules root ["celo"];

  mkModuleOptionDesc = path: description: options: lib.setAttrByPath path ({
    enable = lib.mkEnableOption description;
  } // options);
  mkModuleOption = path: mkModuleOptionDesc path (lib.last path);
  mkModuleSimple = path: mkModuleOption path {};

  getModuleOption = path: config: lib.getAttrFromPath [config] ++ path;

  mkColorOption = name: default: lib.mkOption {
    type = lib.types.nonEmptyStr;
    description = "Color in hex for `${name}`";
    default = default;
    example = "ffa500";
  };
in {
  inherit
    load
    mkModuleOptionDesc
    mkModuleOption
    mkModuleEnable
    mkColorOption
  ;
}
