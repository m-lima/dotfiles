{
  system = "aarch64-darwin";
  module = {
    celo = {
      profiles = {
        darwin.enable = true;
        base.enable = true;
        # dev.enable = true;
        # nextcloud.enable = true;
      };

      programs = {
        simpalt = {
          symbol = "⏾";
        };
      };
    };
  };
}
