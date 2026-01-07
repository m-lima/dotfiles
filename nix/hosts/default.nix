{
  # Gets a list of host configurations for a given kind
  #
  # Input:
  # kind - The kind of host. I.e. the directory under `./.`
  #
  # Output:
  # An attribute set, with each host. The key is the host id, and the
  # value is the list of modules for that host
  for =
    kind:
    let
      # [Util] Returns a list of attr names that pass the filter
      filterAttrNames =
        filter: attrs: builtins.filter (name: filter attrs.${name}) (builtins.attrNames attrs);

      # Gets the host ids for a given kind
      # I.e. the directory name under `./${kind}`
      #
      # Returns a list of id strings
      hostIds = filterAttrNames (x: x == "directory") (builtins.readDir ./${kind});

      # Loads the definition of a host id
      # The definition comes from importing `./${kind}/${id}`
      #
      # Returns:
      # {
      #   id         - Id of the host
      #   definition - The imported definition for the given host
      # }
      toDefinition = id: {
        inherit id;
        definition = import ./${kind}/${id};
      };

      # Builds a list of modules to load for this configuration
      # Takes the host id and definition and adds default configuration values and ragenix configuration
      #
      # Returns
      # {
      #   id      - Id of the host, the name of the directory (also available in config.celo.host.id)
      #   modules - Modules to load for this host
      # }
      toModules = host: {
        name = host.id;
        value = [
          host.definition
          (
            { lib, config, ... }:
            {
              options = {
                celo = {
                  host = {
                    id = lib.mkOption {
                      default = host.id;
                      type = lib.types.nonEmptyStr;
                      description = "A unique identifier for this host";
                      readOnly = true;
                    };
                    kind = lib.mkOption {
                      default = kind;
                      type = lib.types.enum [
                        "nixos"
                        "darwin"
                      ];
                      description = "The kind of host being built";
                      readOnly = true;
                    };
                  };
                };
              };

              config = {
                ragenix.key = lib.mkDefault config.celo.modules.core.agenix.identityPath;
              };

            }
          )
        ];
      };
    in
    builtins.listToAttrs (map toModules (map toDefinition hostIds));
}
