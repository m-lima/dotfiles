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
    environment.systemPackages =
      let
        flake = "${config.celo.modules.core.user.homeDirectory}/code/dotfiles/nix";
        arch = if pkgs.stdenv.isLinux then "nixos" else "darwin";
        scopeInit = ''
          flake = builtins.getFlake "${flake}";
          configuration = flake.${arch}Configurations."${config.celo.host.id}";
          scope =
            assert configuration._type or null == "configuration";
            assert configuration.class or "${arch}" == "${arch}";
            configuration._module.args
            // configuration._module.specialArgs
            // {
              inherit (configuration) config options;
              lib = configuration.lib or configuration.pkgs.lib;
              inherit flake;
            };
        '';
      in
      [
        (pkgs.writeShellScriptBin "nixrpl" ''
          nix --extra-experimental-features 'nix-command flakes' repl --impure --expr '# vim: set syntax=nix:
            let
              motd = "Loaded system flake `${flake}` for `${config.celo.host.id}`";
              ${scopeInit}
            in
            builtins.seq scope builtins.trace motd scope
            '
        '')
        (pkgs.writeShellScriptBin "nixexpr" ''
          if [[ "$1" == "--raw" ]]; then
            RAW="--raw"
            shift
          fi

          if (( $# != 1 )); then
            echo "Expected an EXPR argument" >&2
            exit 1
          fi

          nix --extra-experimental-features 'nix-command flakes' eval --impure $RAW --expr '
            let
              ${scopeInit}
            in
            with scope; '"$@"
        '')
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
