{ lib, ... }:
{
  options = {
    celo = {
      hostId = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "A unique identifier for this host";
        example = "coal";
      };
    };
  };
}
