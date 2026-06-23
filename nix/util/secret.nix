{ lib }:
let
  mkPath =
    path: name:
    let
      cleanName = if lib.hasSuffix ".age" name then lib.strings.removeSuffix ".age" name else name;
    in
    builtins.concatStringsSep "." (builtins.tail (builtins.tail path)) + ".${cleanName}";

  optional =
    config: secret:
    if builtins.hasAttr "decrypt" builtins then
      let
        result = builtins.decrypt /${builtins.toPath config.ragenix.key} secret;
      in
      if builtins.hasAttr "ok" result then
        builtins.trace "ragenix: Decrypted ${secret}" [
          result.ok
        ]
      else
        builtins.warn "${result.err}. Skipping ${secret}" [ ]
    else
      builtins.warn "Ragenix is not yet initialized. Skipping ${secret}" [ ];

  orElse =
    config: secret: default:
    let
      maybeSecret = optional config secret;
    in
    if builtins.length maybeSecret > 0 then builtins.head maybeSecret else default;

  mapOrElse =
    config: secret: mapper: default:
    let
      maybeSecret = map mapper (optional config secret);
    in
    if builtins.length maybeSecret > 0 then builtins.head maybeSecret else default;

  mkIf = config: secret: orElse config secret (lib.mkIf false { });

  mkMapIf =
    config: secret: mapper:
    mapOrElse config secret mapper (lib.mkIf false { });

in
{
  inherit mkPath;
  rage = {
    inherit
      optional
      orElse
      mapOrElse
      mkIf
      mkMapIf
      ;
  };
}
