{
  lib,
  getOptions,
  mkOptions,
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

  mkProfile = path: config: profile: {
    options = mkOptions path { description = "${lib.last path} profile"; };
    config.celo.modules = lib.mkIf (getOptions path config).enable profile;
  };

  modules =
    root:
    map ({ file, path }: (import file) path) (
      findFiles "mod" root [
        "celo"
        "modules"
      ]
    );

  profiles =
    root:
    map ({ file, path }: { config, ... }: mkProfile path config (import file)) (
      findFiles "pro" root [
        "celo"
        "profiles"
      ]
    );
in
{
  inherit
    modules
    profiles
    ;
}
