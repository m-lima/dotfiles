path:
{
  config,
  lib,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    bazelisk = lib.mkEnableOption "bazelisk" // {
      default = true;
    };
    alias = lib.mkEnableOption "bazel alias for bazelisk" // {
      default = true;
    };
  };

  config = util.given.enforcedHome path config cfg.enable {
    assertions = [
      {
        assertion = cfg.alias -> cfg.bazelisk;
        message = "Alias for bazelisk can only be set if bazelisk is enabled";
      }
    ];
    home-manager = {
      home.packages =
        if cfg.bazelisk then
          if cfg.alias then
            [ (pkgs.writeShellScriptBin "bazel" ''exec "${pkgs.lib.getBin pkgs.bazelisk}/bin/bazelisk" "$@"'') ]
          else
            [ pkgs.bazelisk ]
        else
          [ pkgs.bazel ];
    };
  };
}
