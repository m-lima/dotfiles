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
      (
        let
          flake = "${config.celo.modules.core.user.homeDirectory}/code/dotfiles/nix";
        in
        pkgs.writeShellScriptBin "nixrpl" ''
          nix --extra-experimental-features 'nix-command flakes' repl --impure --expr '# vim: set syntax=nix:
            let
              flake = builtins.getFlake "${flake}";
              configuration = flake.${
                if pkgs.stdenv.isLinux then "nixosConfigurations" else "darwinConfigurations"
              }."${config.celo.host.id}";
              motd = "Loaded system flake `${flake}` for `${config.celo.host.id}`";
              scope =
                assert configuration._type or null == "configuration";
                assert configuration.class or "nixos" == "nixos";
                configuration._module.args
                // configuration._module.specialArgs
                // {
                  inherit (configuration) config options;
                  lib = configuration.lib or configuration.pkgs.lib;
                  inherit flake;
                };
            in
            builtins.seq scope builtins.trace motd scope
            '
        ''
      )
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
