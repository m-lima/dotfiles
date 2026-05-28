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
      (pkgs.writeShellScriptBin "nixshell" ''
        if [ $1 ]; then
          PKG="$1"
        else
          echo 'No package provided'
          exit 1
        fi
        shift
        nix-shell --run "env NIX_SHELL=\"''${NIX_SHELL:+''${NIX_SHELL} }$PKG\" zsh" -p $PKG $@
      '')
    ];
  };
}
