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
        fg = util.sgr.fg;
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
            echo "${fg.red}Error:${fg.reset} Expected an EXPR argument" >&2
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
        (pkgs.writeShellScriptBin "nixmatch" ''
          if (( $# > 2 )); then
            echo "Expected an optional flake.lock path argument and an optional reference lock file" >&2
            exit 1
          fi

          TARGET="./flake.lock"
          if (( $# > 0 )); then
            if [[ "$(basename "$1")" != "flake.lock" ]]; then
              echo "${fg.red}Error:${fg.reset} Expected a flake.lock path argument as target" >&2
              exit 1
            else
              TARGET="$1"
            fi

            if ! [ -f "$TARGET" ]; then
              echo "${fg.red}Error:${fg.reset} Expected a flake.lock target path argument" >&2
              exit 1
            fi
          fi

          REFERENCE="$HOME/code/dotfiles/nix/flake.lock"
          if (( $# > 1 )); then
            if [[ "$(basename "$2")" != "flake.lock" ]]; then
              echo "${fg.red}Error:${fg.reset} Expected a flake.lock path argument as reference" >&2
              exit 1
            else
              REFERENCE="$2"
            fi

            if ! [ -f "$REFERENCE" ]; then
              echo "${fg.red}Error:${fg.reset} Expected a flake.lock reference path argument" >&2
              exit 1
            fi
          fi

          if [[ "$REFERENCE" == "$TARGET" ]]; then
            echo "${fg.yellow}Warning:${fg.reset} The files are the same"
            exit
          fi

          TEMP_FILE="$(mktemp)"

          echo Matching locks from "${fg.white}$REFERENCE${fg.reset}" to "${fg.white}$TARGET${fg.reset}"

          ${pkgs.jq}/bin/jq -s '
            .[0] as $target |
            .[1] as $ref |
            reduce ($target.nodes | keys_unsorted[]) as $node (
              [];
              $target.nodes[$node].original as $original |
              if $original != null then
                ([ $ref.nodes[] | select(.original == $original and .locked != null) ][0]) as $match |
                if $match != null then
                  . += [$match.original]
                else
                  .
                end
              else
                .
              end
            )
          ' "$TARGET" "$REFERENCE"


          ${pkgs.jq}/bin/jq -s '
            .[0] as $target |
            .[1] as $ref |
            reduce ($target.nodes | keys_unsorted[]) as $node (
              $target;
              .nodes[$node].original as $original |
              if $original != null then
                ([ $ref.nodes[] | select(.original == $original and .locked != null) ][0]) as $match |
                if $match != null then
                  .nodes[$node].locked = $match.locked
                else
                  .
                end
              else
                .
              end
            )
          ' "$TARGET" "$REFERENCE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$TARGET"
        '')
      ];
  };
}
