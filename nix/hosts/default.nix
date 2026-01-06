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
  # Returns the configuration for the host
  #
  # Modules:
  # module - What comes from the imported host file
  # hostModule - From below, essentially adds the ID option
  # setupRagenix - Prepares ragenix
  mapHost = module: id: [
    module
    hostModule
    setupRagenix
    {
      celo.host = { inherit id kind; };
    }
  ];
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
          };
        };
      };
    };
  setupRagenix =
    { lib, config, ... }:
    {
      ragenix.key = lib.mkDefault config.celo.modules.core.agenix.identityPath;
    };
in
# For each host directory within `kind`, call the passed in `mkHost` with the
# enriched host definition (as defined above)
builtins.mapAttrs (id: _: mkHost (loadHost id)) listHosts
