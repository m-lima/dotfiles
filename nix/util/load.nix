{
  lib,
}:
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

  mkProfile = name: config: profile: {
    config.celo.modules = lib.mkIf config.celo.profiles.${name}.enable profile;
  };

  modules =
    roots:
    let
      allRoots = lib.flatten (
        map (
          root:
          findFiles "mod" root [
            "celo"
            "modules"
          ]
        ) roots
      );
    in
    map ({ file, path }: (import file) path) allRoots;

  profiles =
    roots:
    let
      allRoots = lib.flatten (
        map (
          root:
          findFiles "pro" root [
            "celo"
            "profiles"
          ]
        ) roots
      );
      names = lib.lists.uniqueStrings (map ({ file, path }: lib.last path) allRoots);

      options = map (name: {
        options.celo.profiles.${name}.enable = lib.mkEnableOption "${name} profile";
      }) names;
      configs = map (
        { file, path }: { config, ... }: mkProfile (lib.last path) config (import file)
      ) allRoots;
    in
    options ++ configs;
in
{
  inherit
    modules
    profiles
    ;
}
