{
  lib,
  ...
}:
let
  findFiles =
    mark:
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
                then findFiles mark fullPath (parents ++ [name])
                else lib.optional (lib.hasSuffix ".${mark}.nix" name)
                  {
                    file = fullPath;
                    path = parents ++ (lib.optional (name != "default.${mark}.nix") (lib.strings.removeSuffix ".${mark}.nix" name));
                  }
            )
          )
        ];
    in
      lib.flatten innerFindModules;
  loadModules = root: map ({file, path}: (import file) path) (findFiles "mod" root ["celo" "module"]);
  loadProfiles = root: map ({file, path}: {config, ...}: mkProfile path config (import file)) (findFiles "pro" root ["celo" "profile"]);

  mkOptions =
    path:
    options@{ description ? (lib.last path), ... }:
    lib.setAttrByPath path (
      { enable = lib.mkEnableOption description; }
      // (removeAttrs options [ "description" ])
    );
  mkOptionsEnable = path: mkOptions path {};

  getOptions = path: config: lib.getAttrFromPath path config;

  # mkInstallMode = mode: lib.mkOption {
  #   description = "Whether to install system-wide or user only";
  #   type = lib.types.oneOf ["sys" "hm"];
  #   example = "hm";
  #   default = mode;
  # };
  # mkInstallSys = mkInstallMode "sys";
  # mkInstallHm = mkInstallMode "hm";

  mkProfile =
    path:
    config:
    profile:
    let
      mkDefault =
        builtins.mapAttrs
        (name: value:
          if (builtins.isAttrs value) then
            mkDefault value
          else
            lib.mkDefault value
        );
    in {
      options = mkOptions path { description = "${lib.last path} profile"; };
      config.celo.module = lib.mkIf (getOptions path config).enable profile;
    };

  mkColorOption = name: default: lib.mkOption {
    type = lib.types.nonEmptyStr;
    description = "Color in hex for `${name}`";
    default = default;
    example = "ffa500";
  };
in {
  inherit
    loadModules
    loadProfiles
    mkOptions
    mkOptionsEnable
    getOptions
    mkColorOption
  ;
}
