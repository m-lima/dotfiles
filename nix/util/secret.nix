{ lib, ... }:
let
  mkPath =
    path: name: lib.strings.concatStringsSep "." (builtins.tail (builtins.tail path)) + ".${name}";

  rage =
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

  rageOptional =
    config: secret:
    let
      maybeSecret = rage config secret;
    in
    lib.mkIf (builtins.length maybeSecret > 0) (builtins.head maybeSecret);

  rageOr =
    config: secret: default:
    let
      maybeSecret = rage config secret;
    in
    if builtins.length maybeSecret > 0 then builtins.head maybeSecret else default;
in
{
  inherit
    mkPath
    rage
    rageOptional
    rageOr
    ;
}
