let
  listHosts = removeAttrs (builtins.readDir ./.) [ "default.nix" ];
  mapHost =
    { system, module }:
    id: {
      inherit system;
      hostModules = [
        module
        hostModule
        { celo.host.id = id; }
      ];
    };
  loadHost = id: mapHost (import ./${id}) id;
  hostModule =
    { lib, ... }:
    {
      options = {
        celo = {
          host = {
            id = lib.mkOption {
              type = lib.types.nonEmptyStr;
              description = "A unique identifier for this host";
            };
          };
        };
      };
    };
in
mkHost: builtins.mapAttrs (id: _: mkHost (loadHost id)) listHosts
