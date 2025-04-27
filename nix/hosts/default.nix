kind: mkHost:
let
  # Load all hosts, with the filenames as ID
  # Excludes this file and loads the directories as hosts
  listHosts = removeAttrs (builtins.readDir ./${kind}) [ "default.nix" ];

  # Imports the host and calls `mapHost` passing the ID as parameter
  loadHost = id: mapHost (import ./${kind}/${id}) id;

  # Takes in the imported host, sets up the mandatory modules (more below),
  # And sets a config entry with the ID field.
  #
  # Returns the following:
  # {
  #   system = <The system type>
  #   hostModules = <Configuration for the host>
  # }
  #
  # Modules:
  # module - What comes from the imported host file
  # hostModule - From below, essentially adds the ID option
  # setupRagenix - Prepares ragenix
  mapHost =
    { system, module }:
    id: {
      inherit system;
      hostModules = [
        module
        hostModule
        setupRagenix
        {
          celo.host = {
            inherit id kind;
            secrets = ./${kind}/${id}/secrets;
          };
          nixpkgs.hostPlatform = system;
        }
      ];
    };
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
            kind = lib.mkOption {
              type = lib.types.enum [
                "nixos"
                "darwin"
              ];
              description = "The kind of host being built";
            };
            secrets = lib.mkOption {
              type = lib.types.path;
              description = "The path to the host secrets";
            };
          };
        };
      };
    };
  setupRagenix =
    { lib, config, ... }:
    {
      ragenix.key = lib.mkDefault (builtins.head config.age.identityPaths);
    };
in
# For each host directory within `kind`, call the passed in `mkHost` with the
# enriched host definition (as defined above)
builtins.mapAttrs (id: _: mkHost (loadHost id)) listHosts
