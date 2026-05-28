path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "flakerpl" ''
        if [ $1 ]; then
          nixpkgs="$1"
        else
          nixpkgs="nixpkgs"
        fi
        nix repl --expr '
        let
          flake = builtins.getFlake "'$PWD'";
          pkgs = flake.inputs.'$nixpkgs'.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          lib = pkgs.lib;
        in
        { inherit flake pkgs lib; }'
      '')
    ];
  };
}
